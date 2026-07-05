import unittest

from app import create_app, db
from app.models import User, UserRole, Conversation, Message


class MessagingContactsTests(unittest.TestCase):
    def setUp(self):
        self.app = create_app()
        self.app.config['TESTING'] = True
        self.app.config['WTF_CSRF_ENABLED'] = False
        self.app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
        self.client = self.app.test_client()

        with self.app.app_context():
            db.drop_all()
            db.create_all()

            farmer = User(
                username='farmer_test',
                email='farmer_test@example.com',
                role=UserRole.FARMER,
                first_name='Farmer',
                last_name='One',
            )
            farmer.set_password('pass')

            supplier = User(
                username='supplier_test',
                email='supplier_test@example.com',
                role=UserRole.FEED_SUPPLIER,
                first_name='Supplier',
                last_name='One',
            )
            supplier.set_password('pass')

            vet = User(
                username='vet_test',
                email='vet_test@example.com',
                role=UserRole.VETERINARIAN,
                first_name='Vet',
                last_name='One',
            )
            vet.set_password('pass')

            db.session.add_all([farmer, supplier, vet])
            db.session.commit()
            self.farmer_id = farmer.id

    def test_farmer_contacts_endpoint_lists_available_vet_and_supplier_accounts(self):
        with self.client.session_transaction() as sess:
            sess['_user_id'] = str(self.farmer_id)
            sess['_fresh'] = True

        response = self.client.get('/messaging/contacts')
        self.assertEqual(response.status_code, 200)

        payload = response.get_json()
        self.assertGreaterEqual(len(payload), 2)
        names = {item['name'] for item in payload}
        self.assertIn('Supplier One', names)
        self.assertIn('Vet One', names)

    def test_farmer_can_start_conversation_with_selected_contact(self):
        with self.client.session_transaction() as sess:
            sess['_user_id'] = str(self.farmer_id)
            sess['_fresh'] = True

        response = self.client.post(
            '/messaging/start',
            data={'participant_id': 2},
            headers={'X-Requested-With': 'XMLHttpRequest'},
        )

        self.assertEqual(response.status_code, 200)
        payload = response.get_json()
        self.assertTrue(payload['ok'])
        self.assertIn('conversation_id', payload)

    def test_supplier_contacts_endpoint_lists_farmer_accounts_and_opens_chat(self):
        with self.app.app_context():
            supplier = User.query.filter_by(username='supplier_test').first()

        with self.client.session_transaction() as sess:
            sess['_user_id'] = str(supplier.id)
            sess['_fresh'] = True

        response = self.client.get('/messaging/contacts')
        self.assertEqual(response.status_code, 200)
        payload = response.get_json()
        self.assertTrue(isinstance(payload, list))
        self.assertGreaterEqual(len(payload), 1)
        names = {item['name'] for item in payload}
        self.assertIn('Farmer One', names)

        start_response = self.client.post(
            '/messaging/start',
            data={'participant_id': self.farmer_id},
            headers={'X-Requested-With': 'XMLHttpRequest'},
        )
        self.assertEqual(start_response.status_code, 200)
        start_payload = start_response.get_json()
        self.assertTrue(start_payload['ok'])
        self.assertIn('conversation_id', start_payload)

    def test_conversations_summary_lists_recent_messages_and_unread_state(self):
        with self.app.app_context():
            supplier = User.query.filter_by(username='supplier_test').first()
            conv = Conversation(
                farmer_id=self.farmer_id,
                participant_id=supplier.id,
                participant_role=supplier.role.value,
            )
            db.session.add(conv)
            db.session.commit()
            db.session.add(Message(
                conversation_id=conv.id,
                sender_id=supplier.id,
                receiver_id=self.farmer_id,
                body='Hello from supplier',
            ))
            db.session.commit()

        with self.client.session_transaction() as sess:
            sess['_user_id'] = str(self.farmer_id)
            sess['_fresh'] = True

        response = self.client.get('/messaging/conversations')
        self.assertEqual(response.status_code, 200)

        payload = response.get_json()
        self.assertTrue(isinstance(payload, list))
        self.assertGreaterEqual(len(payload), 1)
        first_item = payload[0]
        self.assertEqual(first_item['conversation_id'], 1)
        self.assertEqual(first_item['preview'], 'Hello from supplier')
        self.assertEqual(first_item['unread_count'], 1)

    def test_send_and_receive_messages_across_farmer_and_supplier(self):
        with self.app.app_context():
            supplier = User.query.filter_by(username='supplier_test').first()
            conv = Conversation(
                farmer_id=self.farmer_id,
                participant_id=supplier.id,
                participant_role=supplier.role.value,
            )
            db.session.add(conv)
            db.session.commit()

        with self.client.session_transaction() as sess:
            sess['_user_id'] = str(self.farmer_id)
            sess['_fresh'] = True

        send_response = self.client.post(
            '/messaging/conversation/1/send',
            data={'body': 'Hello supplier'},
            headers={'X-Requested-With': 'XMLHttpRequest'},
        )
        self.assertEqual(send_response.status_code, 200)

        with self.client.session_transaction() as sess:
            sess['_user_id'] = str(2)
            sess['_fresh'] = True

        poll_response = self.client.get('/messaging/conversation/1/poll?last_id=0')
        self.assertEqual(poll_response.status_code, 200)

        payload = poll_response.get_json()
        self.assertTrue(isinstance(payload, list))
        self.assertGreaterEqual(len(payload), 1)
        self.assertEqual(payload[0]['body'], 'Hello supplier')


if __name__ == '__main__':
    unittest.main()
