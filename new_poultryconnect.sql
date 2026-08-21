BEGIN TRANSACTION;
CREATE TABLE alembic_version (
	version_num VARCHAR(32) NOT NULL, 
	CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);
INSERT INTO "alembic_version" VALUES('d3050d4ded93');
CREATE TABLE buyer_feedback (
	id INTEGER NOT NULL, 
	buyer_id INTEGER NOT NULL, 
	order_id INTEGER, 
	category VARCHAR(8) NOT NULL, 
	rating INTEGER, 
	feedback_text TEXT NOT NULL, 
	ai_issue VARCHAR(100), 
	ai_sentiment VARCHAR(20), 
	ai_keywords VARCHAR(500), 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, product_id INTEGER REFERENCES products(id), farmer_id INTEGER REFERENCES users(id), 
	PRIMARY KEY (id), 
	FOREIGN KEY(buyer_id) REFERENCES users (id), 
	FOREIGN KEY(order_id) REFERENCES orders (id)
);
INSERT INTO "buyer_feedback" VALUES(1,2,10,'product',5,'The eggs were perfectly fresh and delivery was fast!','Fresh eggs and fast delivery','Positive','["eggs", "fresh", "delivery", "fast"]','2026-08-21 16:23:49.075988','2026-08-21 16:41:04.789460',NULL,1);
INSERT INTO "buyer_feedback" VALUES(2,2,41,'delivery',2,'mabagal yun delivery','slow delivery','Negative','["mabagal", "delivery", "slow delivery"]','2026-08-21 16:23:49.080015','2026-08-21 16:41:04.796157',NULL,1);
INSERT INTO "buyer_feedback" VALUES(3,2,55,'delivery',5,'fast delivery','fast delivery','Positive','["fast", "delivery"]','2026-08-21 16:23:49.081084','2026-08-21 16:41:04.797508',NULL,1);
INSERT INTO "buyer_feedback" VALUES(4,2,67,'website',4,'mabilis naman',NULL,'Positive','["mabilis", "fast", "delivery"]','2026-08-21 17:45:53.392759','2026-08-21 17:45:53.392770',NULL,NULL);
INSERT INTO "buyer_feedback" VALUES(5,2,67,'product',5,'okay lang',NULL,'Neutral','["okay", "lang", "average", "acceptable"]','2026-08-21 17:46:16.313289','2026-08-21 17:46:16.313296',6,1);
INSERT INTO "buyer_feedback" VALUES(6,2,67,'delivery',4,'mabilis',NULL,'Positive','["mabilis", "fast", "delivery"]','2026-08-21 17:46:16.313301','2026-08-21 17:46:16.313304',NULL,1);
INSERT INTO "buyer_feedback" VALUES(7,2,4,'website',3,'',NULL,NULL,NULL,'2026-08-21 17:48:36.042077','2026-08-21 17:48:36.042084',NULL,NULL);
INSERT INTO "buyer_feedback" VALUES(8,2,4,'product',5,'',NULL,NULL,NULL,'2026-08-21 17:48:36.049721','2026-08-21 17:48:36.049727',3,1);
INSERT INTO "buyer_feedback" VALUES(9,2,4,'delivery',4,'',NULL,NULL,NULL,'2026-08-21 17:48:36.049732','2026-08-21 17:48:36.049735',NULL,1);
INSERT INTO "buyer_feedback" VALUES(10,2,40,'website',4,'',NULL,NULL,NULL,'2026-08-21 17:48:53.645206','2026-08-21 17:48:53.645216',NULL,NULL);
INSERT INTO "buyer_feedback" VALUES(11,2,40,'product',5,'',NULL,NULL,NULL,'2026-08-21 17:48:53.648598','2026-08-21 17:48:53.648608',5,1);
INSERT INTO "buyer_feedback" VALUES(12,2,40,'delivery',4,'',NULL,NULL,NULL,'2026-08-21 17:48:53.648616','2026-08-21 17:48:53.648621',NULL,1);
INSERT INTO "buyer_feedback" VALUES(13,2,68,'website',5,'',NULL,NULL,NULL,'2026-08-21 18:24:12.966509','2026-08-21 18:24:12.966517',NULL,NULL);
INSERT INTO "buyer_feedback" VALUES(14,2,68,'product',5,'',NULL,NULL,NULL,'2026-08-21 18:24:12.972049','2026-08-21 18:24:12.972060',5,1);
INSERT INTO "buyer_feedback" VALUES(15,2,68,'delivery',5,'',NULL,NULL,NULL,'2026-08-21 18:24:12.972067','2026-08-21 18:24:12.972073',NULL,1);
CREATE TABLE content_moderations (
	id INTEGER NOT NULL, 
	product_id INTEGER, 
	uploader_id INTEGER NOT NULL, 
	image_url VARCHAR(500) NOT NULL, 
	status VARCHAR(8) NOT NULL, 
	ai_result TEXT, 
	ai_flag_reason TEXT, 
	ai_safe BOOLEAN, 
	admin_action TEXT, 
	reviewed_by_id INTEGER, 
	reviewed_at DATETIME, 
	created_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(product_id) REFERENCES products (id), 
	FOREIGN KEY(reviewed_by_id) REFERENCES users (id), 
	FOREIGN KEY(uploader_id) REFERENCES users (id)
);
CREATE TABLE conversations (
	id INTEGER NOT NULL, 
	farmer_id INTEGER NOT NULL, 
	participant_id INTEGER NOT NULL, 
	participant_role VARCHAR(32) NOT NULL, 
	deleted_by_farmer BOOLEAN, 
	deleted_by_participant BOOLEAN, 
	created_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_convo_pair UNIQUE (farmer_id, participant_id), 
	FOREIGN KEY(farmer_id) REFERENCES users (id), 
	FOREIGN KEY(participant_id) REFERENCES users (id)
);
INSERT INTO "conversations" VALUES(1,1,2,'buyer',0,0,'2026-08-21 17:50:45.062487');
CREATE TABLE expenses (
	id INTEGER NOT NULL, 
	farm_id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	expense_date DATE NOT NULL, 
	category VARCHAR(9) NOT NULL, 
	frequency VARCHAR(8) NOT NULL, 
	end_date DATE, 
	amount NUMERIC(10, 2) NOT NULL, 
	description VARCHAR(255), 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(farm_id) REFERENCES farms (id), 
	FOREIGN KEY(user_id) REFERENCES users (id)
);
INSERT INTO "expenses" VALUES(1,1,1,'2026-05-20','feed','one_time',NULL,15901.1675969456,'Weekly feed supply','2026-08-18 11:45:45.974428','2026-08-18 11:45:45.974434');
INSERT INTO "expenses" VALUES(2,1,1,'2026-05-20','labor','one_time',NULL,1.080941982105089664e+04,'Farm hand wages','2026-08-18 11:45:45.974438','2026-08-18 11:45:45.974441');
INSERT INTO "expenses" VALUES(3,1,1,'2026-05-27','feed','one_time',NULL,1.845161418582528495e+04,'Weekly feed supply','2026-08-18 11:45:46.018527','2026-08-18 11:45:46.018534');
INSERT INTO "expenses" VALUES(4,1,1,'2026-06-01','utilities','one_time',NULL,6.764519424290062488e+03,'Electricity and water bill','2026-08-18 11:45:46.018541','2026-08-18 11:45:46.018546');
INSERT INTO "expenses" VALUES(5,1,1,'2026-06-03','feed','one_time',NULL,1.592522014460676292e+04,'Weekly feed supply','2026-08-18 11:45:46.018552','2026-08-18 11:45:46.018557');
INSERT INTO "expenses" VALUES(6,1,1,'2026-06-04','labor','one_time',NULL,1.069691458853445875e+04,'Farm hand wages','2026-08-18 11:45:46.018561','2026-08-18 11:45:46.018566');
INSERT INTO "expenses" VALUES(7,1,1,'2026-06-10','feed','one_time',NULL,1.954788648107873086e+04,'Weekly feed supply','2026-08-18 11:45:46.018571','2026-08-18 11:45:46.018575');
INSERT INTO "expenses" VALUES(8,1,1,'2026-06-17','feed','one_time',NULL,1.687559942764668813e+04,'Weekly feed supply','2026-08-18 11:45:46.018580','2026-08-18 11:45:46.018585');
INSERT INTO "expenses" VALUES(9,1,1,'2026-06-19','labor','one_time',NULL,1.060664532748415876e+04,'Farm hand wages','2026-08-18 11:45:46.018591','2026-08-18 11:45:46.018595');
INSERT INTO "expenses" VALUES(10,1,1,'2026-06-24','feed','one_time',NULL,1.902552934060154803e+04,'Weekly feed supply','2026-08-18 11:45:46.018600','2026-08-18 11:45:46.018605');
INSERT INTO "expenses" VALUES(11,1,1,'2026-07-01','feed','one_time',NULL,1.663925635549261642e+04,'Weekly feed supply','2026-08-18 11:45:46.018610','2026-08-18 11:45:46.018614');
INSERT INTO "expenses" VALUES(12,1,1,'2026-07-01','utilities','one_time',NULL,6.33019180664212945e+03,'Electricity and water bill','2026-08-18 11:45:46.018620','2026-08-18 11:45:46.018624');
INSERT INTO "expenses" VALUES(13,1,1,'2026-07-04','labor','one_time',NULL,1.010588889411459604e+04,'Farm hand wages','2026-08-18 11:45:46.018629','2026-08-18 11:45:46.018634');
INSERT INTO "expenses" VALUES(14,1,1,'2026-07-08','feed','one_time',NULL,1.576378085129848841e+04,'Weekly feed supply','2026-08-18 11:45:46.018639','2026-08-18 11:45:46.018644');
INSERT INTO "expenses" VALUES(15,1,1,'2026-07-15','feed','one_time',NULL,1.84462882626004357e+04,'Weekly feed supply','2026-08-18 11:45:46.018649','2026-08-18 11:45:46.018654');
INSERT INTO "expenses" VALUES(16,1,1,'2026-07-19','labor','one_time',NULL,1.161490337765682307e+04,'Farm hand wages','2026-08-18 11:45:46.018660','2026-08-18 11:45:46.018665');
INSERT INTO "expenses" VALUES(17,1,1,'2026-07-22','feed','one_time',NULL,1.737299072049426105e+04,'Weekly feed supply','2026-08-18 11:45:46.018670','2026-08-18 11:45:46.018675');
INSERT INTO "expenses" VALUES(18,1,1,'2026-07-29','feed','one_time',NULL,1.660262859602412209e+04,'Weekly feed supply','2026-08-18 11:45:46.018680','2026-08-18 11:45:46.018685');
INSERT INTO "expenses" VALUES(19,1,1,'2026-08-01','utilities','one_time',NULL,5.077128530887091984e+03,'Electricity and water bill','2026-08-18 11:45:46.018690','2026-08-18 11:45:46.018695');
INSERT INTO "expenses" VALUES(20,1,1,'2026-08-03','labor','one_time',NULL,1.199964892580372908e+04,'Farm hand wages','2026-08-18 11:45:46.018700','2026-08-18 11:45:46.018705');
INSERT INTO "expenses" VALUES(21,1,1,'2026-08-05','feed','one_time',NULL,1.619794421177081676e+04,'Weekly feed supply','2026-08-18 11:45:46.018711','2026-08-18 11:45:46.018715');
INSERT INTO "expenses" VALUES(22,1,1,'2026-08-12','feed','one_time',NULL,1.621097382433023085e+04,'Weekly feed supply','2026-08-18 11:45:46.018721','2026-08-18 11:45:46.018726');
INSERT INTO "expenses" VALUES(23,3,1,'2026-08-18','utilities','one_time',NULL,2.509067666657244991e+04,'Auto-seeded UTILITIES expense','2026-08-18 15:29:36.820210','2026-08-18 15:29:36.820217');
INSERT INTO "expenses" VALUES(24,3,1,'2026-08-15','feed','one_time',NULL,7.196517342979711247e+04,'Auto-seeded FEED expense','2026-08-18 15:29:36.832124','2026-08-18 15:29:36.832130');
INSERT INTO "expenses" VALUES(25,3,1,'2026-08-12','labor','one_time',NULL,7.019628367047161737e+04,'Auto-seeded LABOR expense','2026-08-18 15:29:36.836524','2026-08-18 15:29:36.836529');
INSERT INTO "expenses" VALUES(26,3,1,'2026-08-09','feed','one_time',NULL,5.739574771051301651e+04,'Auto-seeded FEED expense','2026-08-18 15:29:36.840906','2026-08-18 15:29:36.840911');
INSERT INTO "expenses" VALUES(27,3,1,'2026-08-06','other','one_time',NULL,4.938350630889863532e+04,'Auto-seeded OTHER expense','2026-08-18 15:29:36.845144','2026-08-18 15:29:36.845149');
INSERT INTO "expenses" VALUES(28,4,1,'2026-08-18','utilities','one_time',NULL,5.353714170753771214e+03,'Auto-seeded UTILITIES expense','2026-08-18 15:29:36.850658','2026-08-18 15:29:36.850664');
INSERT INTO "expenses" VALUES(29,4,1,'2026-08-15','labor','one_time',NULL,1.553157840623139783e+04,'Auto-seeded LABOR expense','2026-08-18 15:29:36.855108','2026-08-18 15:29:36.855113');
INSERT INTO "expenses" VALUES(30,4,1,'2026-08-12','other','one_time',NULL,1.843239648932906857e+04,'Auto-seeded OTHER expense','2026-08-18 15:29:36.859491','2026-08-18 15:29:36.859497');
INSERT INTO "expenses" VALUES(31,4,1,'2026-08-09','labor','one_time',NULL,9.80645359450381874e+03,'Auto-seeded LABOR expense','2026-08-18 15:29:36.864075','2026-08-18 15:29:36.864081');
INSERT INTO "expenses" VALUES(32,4,1,'2026-08-06','feed','one_time',NULL,1.924101294017818873e+04,'Auto-seeded FEED expense','2026-08-18 15:29:36.868773','2026-08-18 15:29:36.868779');
INSERT INTO "expenses" VALUES(33,5,1,'2026-08-18','labor','one_time',NULL,2.228752793060058138e+03,'Auto-seeded LABOR expense','2026-08-18 15:29:36.874050','2026-08-18 15:29:36.874056');
INSERT INTO "expenses" VALUES(34,5,1,'2026-08-15','medicine','one_time',NULL,2.479910669973257881e+03,'Auto-seeded MEDICINE expense','2026-08-18 15:29:36.879246','2026-08-18 15:29:36.879251');
INSERT INTO "expenses" VALUES(35,5,1,'2026-08-12','utilities','one_time',NULL,1.045094112479985143e+03,'Auto-seeded UTILITIES expense','2026-08-18 15:29:36.884810','2026-08-18 15:29:36.884815');
INSERT INTO "expenses" VALUES(36,5,1,'2026-08-09','labor','one_time',NULL,3.711019609010369549e+03,'Auto-seeded LABOR expense','2026-08-18 15:29:36.889297','2026-08-18 15:29:36.889303');
INSERT INTO "expenses" VALUES(37,5,1,'2026-08-06','feed','one_time',NULL,2.412197223822913656e+03,'Auto-seeded FEED expense','2026-08-18 15:29:36.893518','2026-08-18 15:29:36.893524');
CREATE TABLE farmer_verifications (
	id INTEGER NOT NULL, 
	farmer_id INTEGER NOT NULL, 
	status VARCHAR(8) NOT NULL, 
	rejection_reason TEXT, 
	reviewed_by_id INTEGER, 
	reviewed_at DATETIME, 
	notes TEXT, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(farmer_id) REFERENCES users (id), 
	FOREIGN KEY(reviewed_by_id) REFERENCES users (id)
);
INSERT INTO "farmer_verifications" VALUES(1,1,'approved',NULL,4,'2026-08-21 15:35:01.881085',NULL,'2026-08-21 15:35:01.882925','2026-08-21 15:35:01.882932');
CREATE TABLE farms (
	id INTEGER NOT NULL, 
	farmer_id INTEGER NOT NULL, 
	name VARCHAR(120) NOT NULL, 
	location VARCHAR(255), 
	description TEXT, 
	flock_size INTEGER, 
	is_active BOOLEAN NOT NULL, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(farmer_id) REFERENCES users (id)
);
INSERT INTO "farms" VALUES(1,1,'Sunshine Poultry Farm','San Jose, Batangas','Family-owned layer farm specializing in fresh eggs.',4819,1,'2026-08-18 11:45:45.934278','2026-08-18 11:45:46.017318');
INSERT INTO "farms" VALUES(2,3,'My Test Farm','Test Location',NULL,95,1,'2026-08-18 12:54:48.573872','2026-08-18 12:58:52.086655');
INSERT INTO "farms" VALUES(3,1,'Sunrise Hills Poultry','Batangas',NULL,15000,1,'2026-08-18 15:21:33.092571','2026-08-18 15:21:33.092585');
INSERT INTO "farms" VALUES(4,1,'Green Valley Layers','Laguna',NULL,4499,1,'2026-08-18 15:21:33.097533','2026-08-18 15:34:50.899825');
INSERT INTO "farms" VALUES(5,1,'Backyard Coops','Quezon',NULL,799,1,'2026-08-18 15:21:33.098820','2026-08-18 15:34:37.025763');
CREATE TABLE "feed_records" (
	id INTEGER NOT NULL, 
	farm_id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	record_date DATE NOT NULL, 
	feed_type VARCHAR(100) NOT NULL, 
	feed_consumed_kg NUMERIC(8, 2) DEFAULT (0.00), 
	feed_cost NUMERIC(10, 2) DEFAULT (0.00), 
	notes TEXT, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(farm_id) REFERENCES farms (id), 
	FOREIGN KEY(user_id) REFERENCES users (id)
);
CREATE TABLE flock_history (
	id INTEGER NOT NULL, 
	farm_id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	date DATE NOT NULL, 
	change_type VARCHAR(50) NOT NULL, 
	quantity INTEGER NOT NULL, 
	notes TEXT, 
	created_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(farm_id) REFERENCES farms (id), 
	FOREIGN KEY(user_id) REFERENCES users (id)
);
INSERT INTO "flock_history" VALUES(1,1,1,'2026-05-20','initial',5000,'Initial batch of layer hens.','2026-08-18 11:45:45.946951');
INSERT INTO "flock_history" VALUES(2,1,1,'2026-05-20','mortality',-2,'Daily mortality.','2026-08-18 11:45:45.982542');
INSERT INTO "flock_history" VALUES(3,1,1,'2026-05-20','mortality',-2,'Daily mortality.','2026-08-18 11:45:45.987487');
INSERT INTO "flock_history" VALUES(4,1,1,'2026-05-21','mortality',-2,'Daily mortality.','2026-08-18 11:45:45.989643');
INSERT INTO "flock_history" VALUES(5,1,1,'2026-05-22','mortality',-1,'Daily mortality.','2026-08-18 11:45:45.994307');
INSERT INTO "flock_history" VALUES(6,1,1,'2026-05-22','mortality',-1,'Daily mortality.','2026-08-18 11:45:45.994313');
INSERT INTO "flock_history" VALUES(7,1,1,'2026-05-23','mortality',-1,'Daily mortality.','2026-08-18 11:45:45.994316');
INSERT INTO "flock_history" VALUES(8,1,1,'2026-05-23','mortality',-2,'Daily mortality.','2026-08-18 11:45:45.994320');
INSERT INTO "flock_history" VALUES(9,1,1,'2026-05-24','mortality',-1,'Daily mortality.','2026-08-18 11:45:45.994323');
INSERT INTO "flock_history" VALUES(10,1,1,'2026-05-25','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021796');
INSERT INTO "flock_history" VALUES(11,1,1,'2026-05-26','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021816');
INSERT INTO "flock_history" VALUES(12,1,1,'2026-05-27','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021821');
INSERT INTO "flock_history" VALUES(13,1,1,'2026-05-27','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021825');
INSERT INTO "flock_history" VALUES(14,1,1,'2026-05-30','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021828');
INSERT INTO "flock_history" VALUES(15,1,1,'2026-05-31','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021831');
INSERT INTO "flock_history" VALUES(16,1,1,'2026-05-31','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021834');
INSERT INTO "flock_history" VALUES(17,1,1,'2026-06-01','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021837');
INSERT INTO "flock_history" VALUES(18,1,1,'2026-06-02','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021840');
INSERT INTO "flock_history" VALUES(19,1,1,'2026-06-03','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021843');
INSERT INTO "flock_history" VALUES(20,1,1,'2026-06-03','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021846');
INSERT INTO "flock_history" VALUES(21,1,1,'2026-06-04','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021849');
INSERT INTO "flock_history" VALUES(22,1,1,'2026-06-06','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021852');
INSERT INTO "flock_history" VALUES(23,1,1,'2026-06-06','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021855');
INSERT INTO "flock_history" VALUES(24,1,1,'2026-06-07','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021858');
INSERT INTO "flock_history" VALUES(25,1,1,'2026-06-08','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021861');
INSERT INTO "flock_history" VALUES(26,1,1,'2026-06-09','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021864');
INSERT INTO "flock_history" VALUES(27,1,1,'2026-06-10','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021868');
INSERT INTO "flock_history" VALUES(28,1,1,'2026-06-10','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021870');
INSERT INTO "flock_history" VALUES(29,1,1,'2026-06-11','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021874');
INSERT INTO "flock_history" VALUES(30,1,1,'2026-06-12','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021877');
INSERT INTO "flock_history" VALUES(31,1,1,'2026-06-12','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021880');
INSERT INTO "flock_history" VALUES(32,1,1,'2026-06-13','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021883');
INSERT INTO "flock_history" VALUES(33,1,1,'2026-06-15','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021886');
INSERT INTO "flock_history" VALUES(34,1,1,'2026-06-16','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021889');
INSERT INTO "flock_history" VALUES(35,1,1,'2026-06-16','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021892');
INSERT INTO "flock_history" VALUES(36,1,1,'2026-06-17','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021895');
INSERT INTO "flock_history" VALUES(37,1,1,'2026-06-17','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021898');
INSERT INTO "flock_history" VALUES(38,1,1,'2026-06-18','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021901');
INSERT INTO "flock_history" VALUES(39,1,1,'2026-06-19','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021904');
INSERT INTO "flock_history" VALUES(40,1,1,'2026-06-20','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021907');
INSERT INTO "flock_history" VALUES(41,1,1,'2026-06-21','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021910');
INSERT INTO "flock_history" VALUES(42,1,1,'2026-06-22','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021913');
INSERT INTO "flock_history" VALUES(43,1,1,'2026-06-22','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021916');
INSERT INTO "flock_history" VALUES(44,1,1,'2026-06-23','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021919');
INSERT INTO "flock_history" VALUES(45,1,1,'2026-06-24','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021922');
INSERT INTO "flock_history" VALUES(46,1,1,'2026-06-24','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021925');
INSERT INTO "flock_history" VALUES(47,1,1,'2026-06-25','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021928');
INSERT INTO "flock_history" VALUES(48,1,1,'2026-06-27','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021932');
INSERT INTO "flock_history" VALUES(49,1,1,'2026-06-27','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021935');
INSERT INTO "flock_history" VALUES(50,1,1,'2026-06-28','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021938');
INSERT INTO "flock_history" VALUES(51,1,1,'2026-06-28','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021941');
INSERT INTO "flock_history" VALUES(52,1,1,'2026-06-29','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021944');
INSERT INTO "flock_history" VALUES(53,1,1,'2026-06-30','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021947');
INSERT INTO "flock_history" VALUES(54,1,1,'2026-07-01','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021950');
INSERT INTO "flock_history" VALUES(55,1,1,'2026-07-01','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021953');
INSERT INTO "flock_history" VALUES(56,1,1,'2026-07-02','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021956');
INSERT INTO "flock_history" VALUES(57,1,1,'2026-07-02','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021959');
INSERT INTO "flock_history" VALUES(58,1,1,'2026-07-03','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021962');
INSERT INTO "flock_history" VALUES(59,1,1,'2026-07-03','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021965');
INSERT INTO "flock_history" VALUES(60,1,1,'2026-07-04','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021968');
INSERT INTO "flock_history" VALUES(61,1,1,'2026-07-05','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021971');
INSERT INTO "flock_history" VALUES(62,1,1,'2026-07-05','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021974');
INSERT INTO "flock_history" VALUES(63,1,1,'2026-07-06','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021978');
INSERT INTO "flock_history" VALUES(64,1,1,'2026-07-06','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021981');
INSERT INTO "flock_history" VALUES(65,1,1,'2026-07-07','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021984');
INSERT INTO "flock_history" VALUES(66,1,1,'2026-07-08','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021987');
INSERT INTO "flock_history" VALUES(67,1,1,'2026-07-09','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021990');
INSERT INTO "flock_history" VALUES(68,1,1,'2026-07-10','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.021993');
INSERT INTO "flock_history" VALUES(69,1,1,'2026-07-11','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021996');
INSERT INTO "flock_history" VALUES(70,1,1,'2026-07-11','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.021999');
INSERT INTO "flock_history" VALUES(71,1,1,'2026-07-12','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022002');
INSERT INTO "flock_history" VALUES(72,1,1,'2026-07-12','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022005');
INSERT INTO "flock_history" VALUES(73,1,1,'2026-07-13','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022008');
INSERT INTO "flock_history" VALUES(74,1,1,'2026-07-14','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022011');
INSERT INTO "flock_history" VALUES(75,1,1,'2026-07-15','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022014');
INSERT INTO "flock_history" VALUES(76,1,1,'2026-07-17','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022017');
INSERT INTO "flock_history" VALUES(77,1,1,'2026-07-17','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022020');
INSERT INTO "flock_history" VALUES(78,1,1,'2026-07-18','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022023');
INSERT INTO "flock_history" VALUES(79,1,1,'2026-07-18','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022026');
INSERT INTO "flock_history" VALUES(80,1,1,'2026-07-19','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022030');
INSERT INTO "flock_history" VALUES(81,1,1,'2026-07-20','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022033');
INSERT INTO "flock_history" VALUES(82,1,1,'2026-07-20','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022036');
INSERT INTO "flock_history" VALUES(83,1,1,'2026-07-21','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022039');
INSERT INTO "flock_history" VALUES(84,1,1,'2026-07-23','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022042');
INSERT INTO "flock_history" VALUES(85,1,1,'2026-07-23','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022045');
INSERT INTO "flock_history" VALUES(86,1,1,'2026-07-24','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022048');
INSERT INTO "flock_history" VALUES(87,1,1,'2026-07-25','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022051');
INSERT INTO "flock_history" VALUES(88,1,1,'2026-07-25','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022054');
INSERT INTO "flock_history" VALUES(89,1,1,'2026-07-27','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022057');
INSERT INTO "flock_history" VALUES(90,1,1,'2026-07-27','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022060');
INSERT INTO "flock_history" VALUES(91,1,1,'2026-07-28','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022063');
INSERT INTO "flock_history" VALUES(92,1,1,'2026-07-28','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022066');
INSERT INTO "flock_history" VALUES(93,1,1,'2026-07-29','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022069');
INSERT INTO "flock_history" VALUES(94,1,1,'2026-07-30','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022075');
INSERT INTO "flock_history" VALUES(95,1,1,'2026-07-31','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022078');
INSERT INTO "flock_history" VALUES(96,1,1,'2026-07-31','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022082');
INSERT INTO "flock_history" VALUES(97,1,1,'2026-08-01','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022085');
INSERT INTO "flock_history" VALUES(98,1,1,'2026-08-01','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022088');
INSERT INTO "flock_history" VALUES(99,1,1,'2026-08-03','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022091');
INSERT INTO "flock_history" VALUES(100,1,1,'2026-08-04','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022094');
INSERT INTO "flock_history" VALUES(101,1,1,'2026-08-04','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022097');
INSERT INTO "flock_history" VALUES(102,1,1,'2026-08-05','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022100');
INSERT INTO "flock_history" VALUES(103,1,1,'2026-08-05','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022103');
INSERT INTO "flock_history" VALUES(104,1,1,'2026-08-06','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022106');
INSERT INTO "flock_history" VALUES(105,1,1,'2026-08-07','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022109');
INSERT INTO "flock_history" VALUES(106,1,1,'2026-08-08','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022112');
INSERT INTO "flock_history" VALUES(107,1,1,'2026-08-09','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022115');
INSERT INTO "flock_history" VALUES(108,1,1,'2026-08-10','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022118');
INSERT INTO "flock_history" VALUES(109,1,1,'2026-08-11','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022121');
INSERT INTO "flock_history" VALUES(110,1,1,'2026-08-12','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022124');
INSERT INTO "flock_history" VALUES(111,1,1,'2026-08-13','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022127');
INSERT INTO "flock_history" VALUES(112,1,1,'2026-08-13','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022130');
INSERT INTO "flock_history" VALUES(113,1,1,'2026-08-14','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022133');
INSERT INTO "flock_history" VALUES(114,1,1,'2026-08-15','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022136');
INSERT INTO "flock_history" VALUES(115,1,1,'2026-08-16','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022139');
INSERT INTO "flock_history" VALUES(116,1,1,'2026-08-16','mortality',-2,'Daily mortality.','2026-08-18 11:45:46.022142');
INSERT INTO "flock_history" VALUES(117,1,1,'2026-08-17','mortality',-1,'Daily mortality.','2026-08-18 11:45:46.022145');
INSERT INTO "flock_history" VALUES(118,2,3,'2026-08-18','initial',100,'Initial flock setup.','2026-08-18 12:54:48.587339');
INSERT INTO "flock_history" VALUES(119,2,3,'2026-08-18','mortality',-5,'Reason: Heat stress','2026-08-18 12:58:52.099424');
INSERT INTO "flock_history" VALUES(120,5,1,'2026-08-18','mortality',-1,'Reason: 1','2026-08-18 15:34:37.032716');
INSERT INTO "flock_history" VALUES(121,4,1,'2026-08-18','mortality',-1,'Reason: 21','2026-08-18 15:34:50.904963');
CREATE TABLE messages (
	id INTEGER NOT NULL, 
	conversation_id INTEGER NOT NULL, 
	sender_id INTEGER NOT NULL, 
	receiver_id INTEGER NOT NULL, 
	body TEXT NOT NULL, 
	sent_at DATETIME NOT NULL, 
	delivered_at DATETIME, 
	seen_at DATETIME, 
	is_seen BOOLEAN NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(conversation_id) REFERENCES conversations (id), 
	FOREIGN KEY(sender_id) REFERENCES users (id), 
	FOREIGN KEY(receiver_id) REFERENCES users (id)
);
INSERT INTO "messages" VALUES(1,1,2,1,'hello','2026-08-21 17:53:34.741597','2026-08-21 17:53:34.734296','2026-08-21 18:01:45.052707',1);
INSERT INTO "messages" VALUES(2,1,1,2,'Hello','2026-08-21 18:01:51.525380','2026-08-21 18:01:51.465476',NULL,0);
CREATE TABLE "mortality_records" (
	id INTEGER NOT NULL, 
	farm_id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	record_date DATE NOT NULL, 
	quantity_died INTEGER DEFAULT 0 NOT NULL, 
	reason VARCHAR(255) NOT NULL, 
	notes TEXT, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(farm_id) REFERENCES farms (id), 
	FOREIGN KEY(user_id) REFERENCES users (id)
);
INSERT INTO "mortality_records" VALUES(1,2,3,'2026-08-18',5,'Heat stress',NULL,'2026-08-18 12:58:52.095133','2026-08-18 12:58:52.095144');
INSERT INTO "mortality_records" VALUES(2,5,1,'2026-08-18',1,'1',NULL,'2026-08-18 15:34:37.035946','2026-08-18 15:34:37.035953');
INSERT INTO "mortality_records" VALUES(3,4,1,'2026-08-18',1,'21',NULL,'2026-08-18 15:34:50.906191','2026-08-18 15:34:50.906200');
CREATE TABLE notifications (
	id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	title VARCHAR(120) NOT NULL, 
	body VARCHAR(255) NOT NULL, 
	notif_type VARCHAR(32) NOT NULL, 
	is_read BOOLEAN NOT NULL, 
	link_url VARCHAR(255), 
	created_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(user_id) REFERENCES users (id)
);
INSERT INTO "notifications" VALUES(1,2,'New Conversation','Maria Reyes started a conversation with you.','message',0,'/messaging/?open=1','2026-08-21 17:50:45.087603');
INSERT INTO "notifications" VALUES(2,1,'New message from Maria Reyes','hello','message',0,'/messaging/?open=1','2026-08-21 17:53:34.744584');
INSERT INTO "notifications" VALUES(3,2,'Message read by Juan Dela Cruz','Juan Dela Cruz has seen your latest message.','seen',0,'/messaging/?open=1','2026-08-21 18:01:45.065549');
INSERT INTO "notifications" VALUES(4,2,'New message from Juan Dela Cruz','Hello','message',0,'/messaging/?open=1','2026-08-21 18:01:51.527952');
CREATE TABLE order_items (
	id INTEGER NOT NULL, 
	order_id INTEGER NOT NULL, 
	product_id INTEGER NOT NULL, 
	quantity INTEGER NOT NULL, 
	unit_price NUMERIC(10, 2) NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(order_id) REFERENCES orders (id), 
	FOREIGN KEY(product_id) REFERENCES products (id)
);
INSERT INTO "order_items" VALUES(1,1,2,19,190);
INSERT INTO "order_items" VALUES(2,2,5,19,185);
INSERT INTO "order_items" VALUES(3,3,6,46,205);
INSERT INTO "order_items" VALUES(4,4,3,47,210);
INSERT INTO "order_items" VALUES(5,5,6,40,205);
INSERT INTO "order_items" VALUES(6,6,3,48,210);
INSERT INTO "order_items" VALUES(7,7,1,47,170);
INSERT INTO "order_items" VALUES(8,8,1,48,170);
INSERT INTO "order_items" VALUES(9,9,2,33,190);
INSERT INTO "order_items" VALUES(10,10,6,35,205);
INSERT INTO "order_items" VALUES(11,11,6,23,205);
INSERT INTO "order_items" VALUES(12,12,6,5,205);
INSERT INTO "order_items" VALUES(13,13,5,43,185);
INSERT INTO "order_items" VALUES(14,14,3,28,210);
INSERT INTO "order_items" VALUES(15,15,5,30,185);
INSERT INTO "order_items" VALUES(16,16,6,29,205);
INSERT INTO "order_items" VALUES(17,17,3,45,210);
INSERT INTO "order_items" VALUES(18,18,4,47,165);
INSERT INTO "order_items" VALUES(19,19,1,6,170);
INSERT INTO "order_items" VALUES(20,20,6,37,205);
INSERT INTO "order_items" VALUES(21,21,6,16,205);
INSERT INTO "order_items" VALUES(22,22,4,20,165);
INSERT INTO "order_items" VALUES(23,23,5,47,185);
INSERT INTO "order_items" VALUES(24,24,3,40,210);
INSERT INTO "order_items" VALUES(25,25,6,45,205);
INSERT INTO "order_items" VALUES(26,26,4,28,165);
INSERT INTO "order_items" VALUES(27,27,4,28,165);
INSERT INTO "order_items" VALUES(28,28,2,7,190);
INSERT INTO "order_items" VALUES(29,29,1,45,170);
INSERT INTO "order_items" VALUES(30,30,1,46,170);
INSERT INTO "order_items" VALUES(31,31,6,23,205);
INSERT INTO "order_items" VALUES(32,32,1,23,170);
INSERT INTO "order_items" VALUES(33,33,5,46,185);
INSERT INTO "order_items" VALUES(34,34,4,13,165);
INSERT INTO "order_items" VALUES(35,35,2,46,190);
INSERT INTO "order_items" VALUES(36,36,4,49,165);
INSERT INTO "order_items" VALUES(37,37,4,33,165);
INSERT INTO "order_items" VALUES(38,38,4,17,165);
INSERT INTO "order_items" VALUES(39,39,5,26,185);
INSERT INTO "order_items" VALUES(40,40,5,44,185);
INSERT INTO "order_items" VALUES(41,41,4,46,165);
INSERT INTO "order_items" VALUES(42,42,1,11,170);
INSERT INTO "order_items" VALUES(43,43,1,29,170);
INSERT INTO "order_items" VALUES(44,44,3,42,210);
INSERT INTO "order_items" VALUES(45,45,1,21,170);
INSERT INTO "order_items" VALUES(46,46,5,29,185);
INSERT INTO "order_items" VALUES(47,47,6,47,205);
INSERT INTO "order_items" VALUES(48,48,5,20,185);
INSERT INTO "order_items" VALUES(49,49,5,42,185);
INSERT INTO "order_items" VALUES(50,50,3,49,210);
INSERT INTO "order_items" VALUES(51,51,5,16,185);
INSERT INTO "order_items" VALUES(52,52,2,49,190);
INSERT INTO "order_items" VALUES(53,53,2,18,190);
INSERT INTO "order_items" VALUES(54,54,1,37,170);
INSERT INTO "order_items" VALUES(55,55,4,13,165);
INSERT INTO "order_items" VALUES(56,56,5,24,185);
INSERT INTO "order_items" VALUES(57,57,5,22,185);
INSERT INTO "order_items" VALUES(58,58,4,25,165);
INSERT INTO "order_items" VALUES(59,59,1,32,170);
INSERT INTO "order_items" VALUES(60,60,6,28,205);
INSERT INTO "order_items" VALUES(61,61,2,38,190);
INSERT INTO "order_items" VALUES(62,62,2,38,190);
INSERT INTO "order_items" VALUES(63,63,6,28,205);
INSERT INTO "order_items" VALUES(64,64,5,50,185);
INSERT INTO "order_items" VALUES(65,65,4,33,165);
INSERT INTO "order_items" VALUES(66,66,1,20,170);
INSERT INTO "order_items" VALUES(67,67,6,34,205);
INSERT INTO "order_items" VALUES(68,68,5,23,185);
INSERT INTO "order_items" VALUES(69,69,3,15,210);
INSERT INTO "order_items" VALUES(70,70,2,36,190);
CREATE TABLE orders (
	id INTEGER NOT NULL, 
	buyer_id INTEGER NOT NULL, 
	total_amount NUMERIC(12, 2) NOT NULL, 
	status VARCHAR(9) NOT NULL, 
	delivery_address VARCHAR(500) NOT NULL, 
	contact_phone VARCHAR(30) NOT NULL, 
	notes TEXT, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, payment_method VARCHAR(50) NOT NULL DEFAULT 'COD', payment_date DATETIME, rating INTEGER, feedback_text TEXT, feedback_category VARCHAR(100), feedback_issue VARCHAR(100), feedback_sentiment VARCHAR(20), feedback_keywords VARCHAR(500), 
	PRIMARY KEY (id), 
	FOREIGN KEY(buyer_id) REFERENCES users (id)
);
INSERT INTO "orders" VALUES(1,2,3610,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-08 09:00:00.000000','2026-06-08 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(2,2,3515,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-16 18:00:00.000000','2026-06-16 18:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(3,2,9430,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-13 08:00:00.000000','2026-06-13 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(4,2,9870,'completed','123 Buyer St, Manila','09189876543',NULL,'2026-08-03 09:00:00.000000','2026-08-21 17:48:36.033580','COD',NULL,1,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(5,2,8200,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-24 14:00:00.000000','2026-06-24 14:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(6,2,10080,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-01 09:00:00.000000','2026-08-01 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(7,2,7990,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-05-25 08:00:00.000000','2026-05-25 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(8,2,8160,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-20 12:00:00.000000','2026-06-20 12:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(9,2,6270,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-26 14:00:00.000000','2026-07-26 14:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(10,2,7175,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-09 10:00:00.000000','2026-08-19 18:34:50.015131','COD',NULL,5,'The eggs were perfectly fresh and delivery was fast!','Eggs','Fresh eggs and fast delivery','Positive','["eggs", "fresh", "delivery", "fast"]');
INSERT INTO "orders" VALUES(11,2,4715,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-21 14:00:00.000000','2026-06-21 14:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(12,2,1025,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-14 11:00:00.000000','2026-08-19 18:33:14.225088','COD',NULL,3,NULL,'General',NULL,'Neutral','[]');
INSERT INTO "orders" VALUES(13,2,7955,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-10 13:00:00.000000','2026-06-10 13:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(14,2,5880,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-02 12:00:00.000000','2026-08-02 12:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(15,2,5550,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-05-28 10:00:00.000000','2026-05-28 10:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(16,2,5945,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-11 16:00:00.000000','2026-07-11 16:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(17,2,9450,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-03 13:00:00.000000','2026-07-03 13:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(18,2,7755,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-30 14:00:00.000000','2026-07-30 14:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(19,2,1020,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-04 09:00:00.000000','2026-08-04 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(20,2,7585,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-30 13:00:00.000000','2026-06-30 13:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(21,2,3280,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-02 12:00:00.000000','2026-07-02 12:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(22,2,3300,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-05-24 16:00:00.000000','2026-05-24 16:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(23,2,8695,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-09 08:00:00.000000','2026-08-09 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(24,2,8400,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-05-30 15:00:00.000000','2026-05-30 15:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(25,2,9225,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-26 13:00:00.000000','2026-07-26 13:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(26,2,4620,'shipped','123 Buyer St, Manila','09189876543',NULL,'2026-08-17 15:00:00.000000','2026-08-17 15:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(27,2,4620,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-25 08:00:00.000000','2026-06-25 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(28,2,1330,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-02 09:00:00.000000','2026-06-02 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(29,2,7650,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-05-25 17:00:00.000000','2026-05-25 17:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(30,2,7820,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-08 12:00:00.000000','2026-07-08 12:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(31,2,4715,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-21 14:00:00.000000','2026-06-21 14:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(32,2,3910,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-23 09:00:00.000000','2026-06-23 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(33,2,8510,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-05-23 09:00:00.000000','2026-05-23 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(34,2,2145,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-14 08:00:00.000000','2026-07-14 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(35,2,8740,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-13 14:00:00.000000','2026-06-13 14:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(36,2,8085,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-21 17:00:00.000000','2026-07-21 17:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(37,2,5445,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-22 15:00:00.000000','2026-07-22 15:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(38,2,2805,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-03 08:00:00.000000','2026-08-03 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(39,2,4810,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-05-29 12:00:00.000000','2026-05-29 12:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(40,2,8140,'completed','123 Buyer St, Manila','09189876543',NULL,'2026-06-07 13:00:00.000000','2026-08-21 17:48:53.639435','COD',NULL,1,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(41,2,7590,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-13 15:00:00.000000','2026-08-19 18:35:12.787418','COD',NULL,2,'mabagal yun delivery','Delivery','slow delivery','Negative','["mabagal", "delivery", "slow delivery"]');
INSERT INTO "orders" VALUES(42,2,1870,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-02 08:00:00.000000','2026-06-02 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(43,2,4930,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-21 16:00:00.000000','2026-06-21 16:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(44,2,8820,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-15 13:00:00.000000','2026-07-15 13:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(45,2,3570,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-04 11:00:00.000000','2026-08-04 11:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(46,2,5365,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-23 11:00:00.000000','2026-07-23 11:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(47,2,9635,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-13 09:00:00.000000','2026-07-13 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(48,2,3700,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-30 11:00:00.000000','2026-06-30 11:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(49,2,7770,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-30 15:00:00.000000','2026-07-30 15:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(50,2,10290,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-03 11:00:00.000000','2026-08-03 11:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(51,2,2960,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-14 17:00:00.000000','2026-07-14 17:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(52,2,9310,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-05-24 10:00:00.000000','2026-05-24 10:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(53,2,3420,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-14 09:00:00.000000','2026-07-14 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(54,2,6290,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-05-21 16:00:00.000000','2026-05-21 16:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(55,2,2145,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-04 09:00:00.000000','2026-08-19 18:35:18.064867','COD',NULL,5,'fast delivery','Delivery','fast delivery','Positive','["fast", "delivery"]');
INSERT INTO "orders" VALUES(56,2,4440,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-23 18:00:00.000000','2026-07-23 18:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(57,2,4070,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-16 08:00:00.000000','2026-06-16 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(58,2,4125,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-08 17:00:00.000000','2026-06-08 17:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(59,2,5440,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-01 18:00:00.000000','2026-07-01 18:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(60,2,5740,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-18 09:00:00.000000','2026-07-18 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(61,2,7220,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-01 13:00:00.000000','2026-07-01 13:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(62,2,7220,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-09 17:00:00.000000','2026-08-09 17:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(63,2,5740,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-26 11:00:00.000000','2026-07-26 11:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(64,2,9250,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-05-22 12:00:00.000000','2026-05-22 12:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(65,2,5445,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-05-28 10:00:00.000000','2026-05-28 10:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(66,2,3400,'shipped','123 Buyer St, Manila','09189876543',NULL,'2026-08-16 11:00:00.000000','2026-08-16 11:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(67,2,6970,'completed','123 Buyer St, Manila','09189876543',NULL,'2026-07-27 11:00:00.000000','2026-08-21 17:45:53.388104','COD',NULL,1,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(68,2,4255,'completed','123 Buyer St, Manila','09189876543',NULL,'2026-07-25 13:00:00.000000','2026-08-21 18:24:12.960850','COD',NULL,1,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(69,2,3150,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-13 10:00:00.000000','2026-08-13 10:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "orders" VALUES(70,2,6840,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-06-27 18:00:00.000000','2026-06-27 18:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
CREATE TABLE production_records (
	id INTEGER NOT NULL, 
	farm_id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	record_date DATE NOT NULL, 
	egg_count INTEGER NOT NULL, 
	size VARCHAR(11), 
	variety VARCHAR(5), 
	feed_kg NUMERIC(8, 2), 
	feed_cost NUMERIC(10, 2), 
	egg_price NUMERIC(10, 2), 
	mortality INTEGER, 
	notes TEXT, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	CONSTRAINT uq_farm_record_date_size_variety UNIQUE (farm_id, record_date, size, variety), 
	FOREIGN KEY(farm_id) REFERENCES farms (id), 
	FOREIGN KEY(user_id) REFERENCES users (id)
);
INSERT INTO "production_records" VALUES(1,1,1,'2026-05-20',2419,'large','white',2.881900941198594524e+02,1.171420057929154154e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:45.984574','2026-08-18 11:45:45.984580');
INSERT INTO "production_records" VALUES(2,1,1,'2026-05-20',1920,'medium','brown',2.975119091537683858e+02,1.084420236779379139e+03,6.333333333333333037e+00,2,NULL,'2026-08-18 11:45:45.987740','2026-08-18 11:45:45.987746');
INSERT INTO "production_records" VALUES(3,1,1,'2026-05-21',2016,'small','brown',2.557772528470012219e+02,1.091966016733978222e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:45.989879','2026-08-18 11:45:45.989885');
INSERT INTO "production_records" VALUES(4,1,1,'2026-05-21',2228,'medium','white',2.994623092434448494e+02,1.147892509794786293e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:45.991114','2026-08-18 11:45:45.991120');
INSERT INTO "production_records" VALUES(5,1,1,'2026-05-22',1512,'large','brown',2.673909098473551466e+02,1.230715090239423717e+03,7,1,NULL,'2026-08-18 11:45:45.996369','2026-08-18 11:45:45.996375');
INSERT INTO "production_records" VALUES(6,1,1,'2026-05-22',2296,'small','brown',2.77007079169199585e+02,1.221615231808596719e+03,5.666666666666666963e+00,1,NULL,'2026-08-18 11:45:45.996379','2026-08-18 11:45:45.996382');
INSERT INTO "production_records" VALUES(7,1,1,'2026-05-23',2051,'medium','white',2.56874391036650934e+02,1.163976461551470493e+03,6.166666666666666963e+00,1,NULL,'2026-08-18 11:45:45.996385','2026-08-18 11:45:45.996388');
INSERT INTO "production_records" VALUES(8,1,1,'2026-05-23',2412,'large','white',2.818756777499067993e+02,1.24326577801359258e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:45.996391','2026-08-18 11:45:45.996394');
INSERT INTO "production_records" VALUES(9,1,1,'2026-05-24',1973,'medium','brown',2.925233940962671113e+02,1.208435423685217757e+03,6.333333333333333037e+00,0,NULL,'2026-08-18 11:45:45.996397','2026-08-18 11:45:45.996400');
INSERT INTO "production_records" VALUES(10,1,1,'2026-05-24',1729,'medium','white',2.651697242220940324e+02,1.247504481985281018e+03,6.166666666666666963e+00,1,NULL,'2026-08-18 11:45:45.996403','2026-08-18 11:45:45.996406');
INSERT INTO "production_records" VALUES(11,1,1,'2026-05-25',1716,'medium','white',2.606593337021016055e+02,1.077839828826852226e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:45.996409','2026-08-18 11:45:45.996412');
INSERT INTO "production_records" VALUES(12,1,1,'2026-05-25',2423,'small','white',2.738324188961072423e+02,1.129937550228368082e+03,5.5,1,NULL,'2026-08-18 11:45:46.029453','2026-08-18 11:45:46.029459');
INSERT INTO "production_records" VALUES(13,1,1,'2026-05-26',1888,'small','brown',2.856449205571466336e+02,1.225825008921462085e+03,5.666666666666666963e+00,0,NULL,'2026-08-18 11:45:46.029462','2026-08-18 11:45:46.029466');
INSERT INTO "production_records" VALUES(14,1,1,'2026-05-26',1699,'large','brown',2.633764448596217562e+02,1.046648243315391938e+03,7,2,NULL,'2026-08-18 11:45:46.029469','2026-08-18 11:45:46.029472');
INSERT INTO "production_records" VALUES(15,1,1,'2026-05-27',2372,'small','brown',2.723576808896377202e+02,1.147463896146682828e+03,5.666666666666666963e+00,1,NULL,'2026-08-18 11:45:46.029475','2026-08-18 11:45:46.029478');
INSERT INTO "production_records" VALUES(16,1,1,'2026-05-27',1788,'large','white',2.54931105993845307e+02,1.246297354625885646e+03,6.833333333333333037e+00,1,NULL,'2026-08-18 11:45:46.029481','2026-08-18 11:45:46.029484');
INSERT INTO "production_records" VALUES(17,1,1,'2026-05-28',1845,'large','brown',2.560809059978145684e+02,1.061781101281369274e+03,7,0,NULL,'2026-08-18 11:45:46.029487','2026-08-18 11:45:46.029490');
INSERT INTO "production_records" VALUES(18,1,1,'2026-05-28',1559,'medium','brown',2.590109305863305735e+02,1.016952422549271204e+03,6.333333333333333037e+00,0,NULL,'2026-08-18 11:45:46.029493','2026-08-18 11:45:46.029496');
INSERT INTO "production_records" VALUES(19,1,1,'2026-05-29',1658,'small','brown',2.90936750107827038e+02,1.024601225427542886e+03,5.666666666666666963e+00,0,NULL,'2026-08-18 11:45:46.029499','2026-08-18 11:45:46.029502');
INSERT INTO "production_records" VALUES(20,1,1,'2026-05-29',2303,'large','brown',2.931740971828704119e+02,1.004456864933684641e+03,7,0,NULL,'2026-08-18 11:45:46.029505','2026-08-18 11:45:46.029508');
INSERT INTO "production_records" VALUES(21,1,1,'2026-05-30',2409,'small','brown',271.880733061082,1.243635689964954963e+03,5.666666666666666963e+00,0,NULL,'2026-08-18 11:45:46.029511','2026-08-18 11:45:46.029514');
INSERT INTO "production_records" VALUES(22,1,1,'2026-05-30',2069,'medium','brown',2.781379530342889552e+02,1.027346521992336193e+03,6.333333333333333037e+00,1,NULL,'2026-08-18 11:45:46.029517','2026-08-18 11:45:46.029520');
INSERT INTO "production_records" VALUES(23,1,1,'2026-05-31',1700,'medium','brown',2.770992086367228922e+02,1.059404374122913168e+03,6.333333333333333037e+00,2,NULL,'2026-08-18 11:45:46.029523','2026-08-18 11:45:46.029526');
INSERT INTO "production_records" VALUES(24,1,1,'2026-05-31',2486,'large','white',2.96016683887525403e+02,1.168365382339767847e+03,6.833333333333333037e+00,1,NULL,'2026-08-18 11:45:46.029529','2026-08-18 11:45:46.029532');
INSERT INTO "production_records" VALUES(25,1,1,'2026-06-01',1997,'large','white',2.993377546196892353e+02,1.17969286852814048e+03,6.833333333333333037e+00,0,NULL,'2026-08-18 11:45:46.029535','2026-08-18 11:45:46.029538');
INSERT INTO "production_records" VALUES(26,1,1,'2026-06-01',2102,'medium','white',2.526993846844407869e+02,1.13436126510486588e+03,6.166666666666666963e+00,2,NULL,'2026-08-18 11:45:46.029541','2026-08-18 11:45:46.029544');
INSERT INTO "production_records" VALUES(27,1,1,'2026-06-02',1537,'medium','brown',2.669695652912171795e+02,1105.57877318468,6.333333333333333037e+00,1,NULL,'2026-08-18 11:45:46.029547','2026-08-18 11:45:46.029550');
INSERT INTO "production_records" VALUES(28,1,1,'2026-06-02',2267,'large','brown',2.636127047645074413e+02,1.133489071665501569e+03,7,0,NULL,'2026-08-18 11:45:46.029553','2026-08-18 11:45:46.029556');
INSERT INTO "production_records" VALUES(29,1,1,'2026-06-03',2435,'large','white',2.576068653553605827e+02,1.146645860783095259e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.029559','2026-08-18 11:45:46.029562');
INSERT INTO "production_records" VALUES(30,1,1,'2026-06-03',1729,'small','brown',2.547244876424890946e+02,1.000585533316496025e+03,5.666666666666666963e+00,1,NULL,'2026-08-18 11:45:46.029565','2026-08-18 11:45:46.029568');
INSERT INTO "production_records" VALUES(31,1,1,'2026-06-04',2080,'medium','white',2.544183918823080717e+02,1.009653915142907863e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.029571','2026-08-18 11:45:46.029574');
INSERT INTO "production_records" VALUES(32,1,1,'2026-06-04',1590,'small','brown',2.579097576300628702e+02,1.033078927569828693e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.029577','2026-08-18 11:45:46.029580');
INSERT INTO "production_records" VALUES(33,1,1,'2026-06-05',2174,'medium','white',2.728439888515054577e+02,1.000194221708332635e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.029583','2026-08-18 11:45:46.029586');
INSERT INTO "production_records" VALUES(34,1,1,'2026-06-05',2163,'medium','brown',2.503276971102813491e+02,1.054871491036918314e+03,6.333333333333333037e+00,0,NULL,'2026-08-18 11:45:46.029589','2026-08-18 11:45:46.029592');
INSERT INTO "production_records" VALUES(35,1,1,'2026-06-06',1855,'large','white',2.503058331257108762e+02,1.098686414339426846e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.029595','2026-08-18 11:45:46.029597');
INSERT INTO "production_records" VALUES(36,1,1,'2026-06-06',2020,'medium','brown',2.672574894498503114e+02,1.092700439979111025e+03,6.333333333333333037e+00,1,NULL,'2026-08-18 11:45:46.029600','2026-08-18 11:45:46.029603');
INSERT INTO "production_records" VALUES(37,1,1,'2026-06-07',2322,'medium','brown',2.669873233256404888e+02,1.088687082349167213e+03,6.333333333333333037e+00,0,NULL,'2026-08-18 11:45:46.029607','2026-08-18 11:45:46.029610');
INSERT INTO "production_records" VALUES(38,1,1,'2026-06-07',2043,'small','brown',2.727468920412754301e+02,1.1015093309651254e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.029614','2026-08-18 11:45:46.029617');
INSERT INTO "production_records" VALUES(39,1,1,'2026-06-08',1856,'small','white',2.579238178462134102e+02,1.158984224159043151e+03,5.5,2,NULL,'2026-08-18 11:45:46.029620','2026-08-18 11:45:46.029623');
INSERT INTO "production_records" VALUES(40,1,1,'2026-06-08',1595,'small','brown',2.609886846667960754e+02,1.241902698324830681e+03,5.666666666666666963e+00,0,NULL,'2026-08-18 11:45:46.029626','2026-08-18 11:45:46.029629');
INSERT INTO "production_records" VALUES(41,1,1,'2026-06-09',1830,'small','white',282.781150205195,1.165659760380762236e+03,5.5,1,NULL,'2026-08-18 11:45:46.029632','2026-08-18 11:45:46.029635');
INSERT INTO "production_records" VALUES(42,1,1,'2026-06-09',2212,'large','white',2.726093629918848365e+02,1.195798156034930117e+03,6.833333333333333037e+00,0,NULL,'2026-08-18 11:45:46.029638','2026-08-18 11:45:46.029641');
INSERT INTO "production_records" VALUES(43,1,1,'2026-06-10',1529,'small','brown',2.820418398370686077e+02,1.022035752849080268e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.029644','2026-08-18 11:45:46.029646');
INSERT INTO "production_records" VALUES(44,1,1,'2026-06-10',2391,'medium','brown',2.916987441173674256e+02,1.147775855864915912e+03,6.333333333333333037e+00,2,NULL,'2026-08-18 11:45:46.029649','2026-08-18 11:45:46.029652');
INSERT INTO "production_records" VALUES(45,1,1,'2026-06-11',2114,'small','brown',2.562879212030693452e+02,1088.80702422436,5.666666666666666963e+00,0,NULL,'2026-08-18 11:45:46.029655','2026-08-18 11:45:46.029658');
INSERT INTO "production_records" VALUES(46,1,1,'2026-06-11',1821,'large','brown',2.539844666825540855e+02,1.01969957663634193e+03,7,1,NULL,'2026-08-18 11:45:46.029661','2026-08-18 11:45:46.029664');
INSERT INTO "production_records" VALUES(47,1,1,'2026-06-12',2022,'medium','brown',2.650516458345775845e+02,1.196866940648622403e+03,6.333333333333333037e+00,2,NULL,'2026-08-18 11:45:46.029667','2026-08-18 11:45:46.029670');
INSERT INTO "production_records" VALUES(48,1,1,'2026-06-12',1780,'large','brown',2.588105444779934601e+02,1.037497738874274318e+03,7,1,NULL,'2026-08-18 11:45:46.029673','2026-08-18 11:45:46.029676');
INSERT INTO "production_records" VALUES(49,1,1,'2026-06-13',2234,'large','white',2.679187474577291823e+02,1.010752257563409103e+03,6.833333333333333037e+00,1,NULL,'2026-08-18 11:45:46.029679','2026-08-18 11:45:46.029682');
INSERT INTO "production_records" VALUES(50,1,1,'2026-06-13',1957,'medium','brown',2.773031899771518738e+02,1.112123910012074929e+03,6.333333333333333037e+00,0,NULL,'2026-08-18 11:45:46.029685','2026-08-18 11:45:46.029688');
INSERT INTO "production_records" VALUES(51,1,1,'2026-06-14',2255,'large','white',2.547707622678635743e+02,1.119353850973128601e+03,6.833333333333333037e+00,0,NULL,'2026-08-18 11:45:46.029691','2026-08-18 11:45:46.029694');
INSERT INTO "production_records" VALUES(52,1,1,'2026-06-14',2363,'small','white',2.555672367440821518e+02,1.237396172814411102e+03,5.5,0,NULL,'2026-08-18 11:45:46.029697','2026-08-18 11:45:46.029700');
INSERT INTO "production_records" VALUES(53,1,1,'2026-06-15',2176,'small','white',2.886467377057607564e+02,1.211420423153105502e+03,5.5,1,NULL,'2026-08-18 11:45:46.029703','2026-08-18 11:45:46.029706');
INSERT INTO "production_records" VALUES(54,1,1,'2026-06-15',2274,'medium','white',2.736723637725982599e+02,1.049520671162439385e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.029709','2026-08-18 11:45:46.029712');
INSERT INTO "production_records" VALUES(55,1,1,'2026-06-16',2101,'medium','white',2.869932886567074207e+02,1.181025405669457087e+03,6.166666666666666963e+00,1,NULL,'2026-08-18 11:45:46.029715','2026-08-18 11:45:46.029718');
INSERT INTO "production_records" VALUES(56,1,1,'2026-06-16',1506,'large','white',2.536792730830371739e+02,1.140649615894881435e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.029721','2026-08-18 11:45:46.029723');
INSERT INTO "production_records" VALUES(57,1,1,'2026-06-17',1677,'large','brown',2.565712707404076127e+02,1.123168432805626935e+03,7,2,NULL,'2026-08-18 11:45:46.029726','2026-08-18 11:45:46.029729');
INSERT INTO "production_records" VALUES(58,1,1,'2026-06-17',2374,'medium','white',2.848138181929274423e+02,1.136715951053454091e+03,6.166666666666666963e+00,1,NULL,'2026-08-18 11:45:46.029732','2026-08-18 11:45:46.029735');
INSERT INTO "production_records" VALUES(59,1,1,'2026-06-18',1883,'large','brown',2.800686368804915674e+02,1.236230597323681196e+03,7,0,NULL,'2026-08-18 11:45:46.029738','2026-08-18 11:45:46.029741');
INSERT INTO "production_records" VALUES(60,1,1,'2026-06-18',1822,'small','brown',2.764056363459610566e+02,1.00930416882006034e+03,5.666666666666666963e+00,1,NULL,'2026-08-18 11:45:46.029744','2026-08-18 11:45:46.029747');
INSERT INTO "production_records" VALUES(61,1,1,'2026-06-19',1840,'small','brown',2.823366150349194754e+02,1.201386516380739522e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.029750','2026-08-18 11:45:46.029753');
INSERT INTO "production_records" VALUES(62,1,1,'2026-06-19',1581,'small','white',2.838851012688439255e+02,1.148278587635167241e+03,5.5,0,NULL,'2026-08-18 11:45:46.029756','2026-08-18 11:45:46.029759');
INSERT INTO "production_records" VALUES(63,1,1,'2026-06-20',1760,'medium','white',2.848073431985148431e+02,1.090164258056352992e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.029762','2026-08-18 11:45:46.029765');
INSERT INTO "production_records" VALUES(64,1,1,'2026-06-20',1563,'large','white',2.594381906495229373e+02,1.042598124798846356e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.029768','2026-08-18 11:45:46.029800');
INSERT INTO "production_records" VALUES(65,1,1,'2026-06-21',2482,'large','brown',2.983402102069735519e+02,1.238198148788389517e+03,7,0,NULL,'2026-08-18 11:45:46.029804','2026-08-18 11:45:46.029806');
INSERT INTO "production_records" VALUES(66,1,1,'2026-06-21',1527,'small','brown',2.552032821828816225e+02,1.007966923940943502e+03,5.666666666666666963e+00,1,NULL,'2026-08-18 11:45:46.029810','2026-08-18 11:45:46.029812');
INSERT INTO "production_records" VALUES(67,1,1,'2026-06-22',2015,'small','white',2.68078752310516279e+02,1.054063378500923136e+03,5.5,1,NULL,'2026-08-18 11:45:46.029815','2026-08-18 11:45:46.029818');
INSERT INTO "production_records" VALUES(68,1,1,'2026-06-22',2365,'large','brown',2.999902882903672889e+02,1.101960982462039283e+03,7,1,NULL,'2026-08-18 11:45:46.029821','2026-08-18 11:45:46.029824');
INSERT INTO "production_records" VALUES(69,1,1,'2026-06-23',2270,'medium','brown',2.644054252873202699e+02,1.216356807698320836e+03,6.333333333333333037e+00,0,NULL,'2026-08-18 11:45:46.029827','2026-08-18 11:45:46.029830');
INSERT INTO "production_records" VALUES(70,1,1,'2026-06-23',2352,'small','white',2.858480967918544592e+02,1.202334499463822795e+03,5.5,2,NULL,'2026-08-18 11:45:46.029833','2026-08-18 11:45:46.029847');
INSERT INTO "production_records" VALUES(71,1,1,'2026-06-24',1719,'medium','brown',2.642444658189515962e+02,1.093934186759740214e+03,6.333333333333333037e+00,2,NULL,'2026-08-18 11:45:46.029851','2026-08-18 11:45:46.029854');
INSERT INTO "production_records" VALUES(72,1,1,'2026-06-24',2320,'small','white',2.55413987969098855e+02,1.180017170026970461e+03,5.5,2,NULL,'2026-08-18 11:45:46.029857','2026-08-18 11:45:46.029860');
INSERT INTO "production_records" VALUES(73,1,1,'2026-06-25',2293,'medium','brown',2.847951168773491872e+02,1.190004968405021146e+03,6.333333333333333037e+00,0,NULL,'2026-08-18 11:45:46.029863','2026-08-18 11:45:46.029866');
INSERT INTO "production_records" VALUES(74,1,1,'2026-06-25',2215,'small','brown',2.635482188762624673e+02,1.22909875627194242e+03,5.666666666666666963e+00,1,NULL,'2026-08-18 11:45:46.029869','2026-08-18 11:45:46.029872');
INSERT INTO "production_records" VALUES(75,1,1,'2026-06-26',2313,'large','white',2.573097088726867696e+02,1.233129336444635783e+03,6.833333333333333037e+00,0,NULL,'2026-08-18 11:45:46.029875','2026-08-18 11:45:46.029878');
INSERT INTO "production_records" VALUES(76,1,1,'2026-06-26',1583,'medium','white',2.701670881183548544e+02,1.006652473499434109e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.029881','2026-08-18 11:45:46.029884');
INSERT INTO "production_records" VALUES(77,1,1,'2026-06-27',2364,'large','white',2.716499723897804301e+02,1.082202439213186154e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.029887','2026-08-18 11:45:46.029890');
INSERT INTO "production_records" VALUES(78,1,1,'2026-06-27',2297,'large','brown',2.709201465434522333e+02,1.202640046012248603e+03,7,1,NULL,'2026-08-18 11:45:46.029893','2026-08-18 11:45:46.029896');
INSERT INTO "production_records" VALUES(79,1,1,'2026-06-28',1654,'small','brown',2.627859278780165368e+02,1.224608044766776629e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.029899','2026-08-18 11:45:46.029902');
INSERT INTO "production_records" VALUES(80,1,1,'2026-06-28',1934,'medium','brown',2.90846753540342604e+02,1.233395997706319121e+03,6.333333333333333037e+00,1,NULL,'2026-08-18 11:45:46.029905','2026-08-18 11:45:46.029908');
INSERT INTO "production_records" VALUES(81,1,1,'2026-06-29',1748,'small','brown',2.508763818376934011e+02,1.133528392316188046e+03,5.666666666666666963e+00,1,NULL,'2026-08-18 11:45:46.029911','2026-08-18 11:45:46.029914');
INSERT INTO "production_records" VALUES(82,1,1,'2026-06-29',1602,'large','white',291.334406037564,1.17984838764322535e+03,6.833333333333333037e+00,0,NULL,'2026-08-18 11:45:46.029917','2026-08-18 11:45:46.029920');
INSERT INTO "production_records" VALUES(83,1,1,'2026-06-30',2450,'medium','white',2.532326092980972874e+02,1.023163181454433243e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.029923','2026-08-18 11:45:46.029926');
INSERT INTO "production_records" VALUES(84,1,1,'2026-06-30',2322,'large','brown',2.661585837009973829e+02,1.078165523000154054e+03,7,2,NULL,'2026-08-18 11:45:46.029929','2026-08-18 11:45:46.029932');
INSERT INTO "production_records" VALUES(85,1,1,'2026-07-01',2200,'large','white',2.761437739266170866e+02,1.183796697946325366e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.029935','2026-08-18 11:45:46.029938');
INSERT INTO "production_records" VALUES(86,1,1,'2026-07-01',1520,'large','brown',2.525021919536860651e+02,1.042163836525838632e+03,7,2,NULL,'2026-08-18 11:45:46.029941','2026-08-18 11:45:46.029943');
INSERT INTO "production_records" VALUES(87,1,1,'2026-07-02',1548,'medium','brown',261.478842123645,1.189603263592869553e+03,6.333333333333333037e+00,1,NULL,'2026-08-18 11:45:46.029946','2026-08-18 11:45:46.029949');
INSERT INTO "production_records" VALUES(88,1,1,'2026-07-02',2228,'medium','white',2.899611026434079122e+02,1.23969942868617295e+03,6.166666666666666963e+00,1,NULL,'2026-08-18 11:45:46.029952','2026-08-18 11:45:46.029955');
INSERT INTO "production_records" VALUES(89,1,1,'2026-07-03',2183,'large','brown',2.995568707516948165e+02,1.018668073344343611e+03,7,2,NULL,'2026-08-18 11:45:46.029958','2026-08-18 11:45:46.029961');
INSERT INTO "production_records" VALUES(90,1,1,'2026-07-03',2264,'small','white',2.865395440523761863e+02,1.207693599362286023e+03,5.5,1,NULL,'2026-08-18 11:45:46.029964','2026-08-18 11:45:46.029967');
INSERT INTO "production_records" VALUES(91,1,1,'2026-07-04',1774,'medium','white',2.650976501659707197e+02,1.078194714519835998e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.029970','2026-08-18 11:45:46.029973');
INSERT INTO "production_records" VALUES(92,1,1,'2026-07-04',1519,'small','white',2.823105736153885914e+02,1.100743040277770434e+03,5.5,2,NULL,'2026-08-18 11:45:46.029976','2026-08-18 11:45:46.029979');
INSERT INTO "production_records" VALUES(93,1,1,'2026-07-05',2328,'large','white',253.931395096241,1.199327339350895045e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.029982','2026-08-18 11:45:46.029985');
INSERT INTO "production_records" VALUES(94,1,1,'2026-07-05',2443,'small','white',2.646650221238797371e+02,1.230057036647103814e+03,5.5,1,NULL,'2026-08-18 11:45:46.029988','2026-08-18 11:45:46.029991');
INSERT INTO "production_records" VALUES(95,1,1,'2026-07-06',1789,'medium','white',2.731343904858558175e+02,1.231617358376072844e+03,6.166666666666666963e+00,2,NULL,'2026-08-18 11:45:46.029994','2026-08-18 11:45:46.029997');
INSERT INTO "production_records" VALUES(96,1,1,'2026-07-06',2209,'large','white',2.992100382498272211e+02,1.205397444410059051e+03,6.833333333333333037e+00,1,NULL,'2026-08-18 11:45:46.030000','2026-08-18 11:45:46.030003');
INSERT INTO "production_records" VALUES(97,1,1,'2026-07-07',2309,'medium','white',2.597664595953407912e+02,1.244179521616979856e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.030006','2026-08-18 11:45:46.030009');
INSERT INTO "production_records" VALUES(98,1,1,'2026-07-07',2003,'small','white',2.919010182052262507e+02,1.24752958033701816e+03,5.5,2,NULL,'2026-08-18 11:45:46.030012','2026-08-18 11:45:46.030015');
INSERT INTO "production_records" VALUES(99,1,1,'2026-07-08',1618,'large','white',2.691521817910706317e+02,1.121831907059911146e+03,6.833333333333333037e+00,1,NULL,'2026-08-18 11:45:46.030018','2026-08-18 11:45:46.030021');
INSERT INTO "production_records" VALUES(100,1,1,'2026-07-08',1892,'small','brown',2.989751369696917891e+02,1.196837281983369167e+03,5.666666666666666963e+00,0,NULL,'2026-08-18 11:45:46.030024','2026-08-18 11:45:46.030026');
INSERT INTO "production_records" VALUES(101,1,1,'2026-07-09',1728,'medium','white',2.631817880957931948e+02,1.048718004922718364e+03,6.166666666666666963e+00,1,NULL,'2026-08-18 11:45:46.030030','2026-08-18 11:45:46.030032');
INSERT INTO "production_records" VALUES(102,1,1,'2026-07-09',2456,'small','white',2.677294150856245097e+02,1.141069248342636911e+03,5.5,0,NULL,'2026-08-18 11:45:46.030035','2026-08-18 11:45:46.030038');
INSERT INTO "production_records" VALUES(103,1,1,'2026-07-10',2141,'small','brown',258.71500896237,1.131553084907703124e+03,5.666666666666666963e+00,0,NULL,'2026-08-18 11:45:46.030041','2026-08-18 11:45:46.030044');
INSERT INTO "production_records" VALUES(104,1,1,'2026-07-10',2236,'large','white',2.534898384991767842e+02,1.158234713010416726e+03,6.833333333333333037e+00,1,NULL,'2026-08-18 11:45:46.030047','2026-08-18 11:45:46.030050');
INSERT INTO "production_records" VALUES(105,1,1,'2026-07-11',1881,'small','brown',2.795753323227114606e+02,1157.5558216022,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.030053','2026-08-18 11:45:46.030056');
INSERT INTO "production_records" VALUES(106,1,1,'2026-07-11',1566,'large','brown',2.525628340573278195e+02,1.114762220532993525e+03,7,2,NULL,'2026-08-18 11:45:46.030059','2026-08-18 11:45:46.030062');
INSERT INTO "production_records" VALUES(107,1,1,'2026-07-12',1752,'large','white',267.543933107303,1.124209447979802235e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.030065','2026-08-18 11:45:46.030068');
INSERT INTO "production_records" VALUES(108,1,1,'2026-07-12',1705,'medium','white',2.980191374613311837e+02,1.118401844639211276e+03,6.166666666666666963e+00,2,NULL,'2026-08-18 11:45:46.030071','2026-08-18 11:45:46.030074');
INSERT INTO "production_records" VALUES(109,1,1,'2026-07-13',2360,'small','white',2.534601594949355103e+02,1.018774751945368734e+03,5.5,0,NULL,'2026-08-18 11:45:46.030077','2026-08-18 11:45:46.030080');
INSERT INTO "production_records" VALUES(110,1,1,'2026-07-13',1511,'small','brown',2.746380981219986097e+02,1.22286053276236521e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.030083','2026-08-18 11:45:46.030086');
INSERT INTO "production_records" VALUES(111,1,1,'2026-07-14',1948,'medium','brown',2.610329635761064537e+02,1.225731637668930943e+03,6.333333333333333037e+00,0,NULL,'2026-08-18 11:45:46.030089','2026-08-18 11:45:46.030092');
INSERT INTO "production_records" VALUES(112,1,1,'2026-07-14',2369,'small','white',2.543410318121256636e+02,1.248299787125189369e+03,5.5,1,NULL,'2026-08-18 11:45:46.030095','2026-08-18 11:45:46.030098');
INSERT INTO "production_records" VALUES(113,1,1,'2026-07-15',2108,'small','white',2.506901759970454577e+02,1.214288166929063436e+03,5.5,0,NULL,'2026-08-18 11:45:46.030101','2026-08-18 11:45:46.030103');
INSERT INTO "production_records" VALUES(114,1,1,'2026-07-15',2270,'medium','brown',2.913255152936135345e+02,1.116001230366873415e+03,6.333333333333333037e+00,1,NULL,'2026-08-18 11:45:46.030106','2026-08-18 11:45:46.030109');
INSERT INTO "production_records" VALUES(115,1,1,'2026-07-16',2122,'large','brown',2.943174001312822838e+02,1.244028168851018335e+03,7,0,NULL,'2026-08-18 11:45:46.030112','2026-08-18 11:45:46.030115');
INSERT INTO "production_records" VALUES(116,1,1,'2026-07-16',1777,'medium','white',2.894714782063831536e+02,1.120710760512655043e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.030118','2026-08-18 11:45:46.030121');
INSERT INTO "production_records" VALUES(117,1,1,'2026-07-17',2009,'large','white',2.530060862707859429e+02,1.120133793266582871e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.030124','2026-08-18 11:45:46.030127');
INSERT INTO "production_records" VALUES(118,1,1,'2026-07-17',1988,'small','brown',2.969512930844804827e+02,1.096872632921300693e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.030130','2026-08-18 11:45:46.030133');
INSERT INTO "production_records" VALUES(119,1,1,'2026-07-18',1598,'small','brown',2.880874181552364349e+02,1.105164258519964732e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.030136','2026-08-18 11:45:46.030139');
INSERT INTO "production_records" VALUES(120,1,1,'2026-07-18',2364,'medium','brown',2.654334675417322842e+02,1.018087027065109624e+03,6.333333333333333037e+00,1,NULL,'2026-08-18 11:45:46.030142','2026-08-18 11:45:46.030145');
INSERT INTO "production_records" VALUES(121,1,1,'2026-07-19',2192,'small','brown',2.95021346811815647e+02,1.060843200265623863e+03,5.666666666666666963e+00,1,NULL,'2026-08-18 11:45:46.030148','2026-08-18 11:45:46.030151');
INSERT INTO "production_records" VALUES(122,1,1,'2026-07-19',2060,'small','white',2.972263889615142034e+02,1.215671317115745751e+03,5.5,0,NULL,'2026-08-18 11:45:46.030154','2026-08-18 11:45:46.030157');
INSERT INTO "production_records" VALUES(123,1,1,'2026-07-20',1925,'large','white',2.994642161360608838e+02,1.006040092694107216e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.030160','2026-08-18 11:45:46.030163');
INSERT INTO "production_records" VALUES(124,1,1,'2026-07-20',2356,'small','brown',2.715018026571108294e+02,1.017016630428984172e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.030166','2026-08-18 11:45:46.030169');
INSERT INTO "production_records" VALUES(125,1,1,'2026-07-21',1527,'large','brown',285.683737511812,1.15652715130414117e+03,7,2,NULL,'2026-08-18 11:45:46.030172','2026-08-18 11:45:46.030175');
INSERT INTO "production_records" VALUES(126,1,1,'2026-07-21',1829,'large','white',2.868999905672086471e+02,1.0837993875100708e+03,6.833333333333333037e+00,0,NULL,'2026-08-18 11:45:46.030178','2026-08-18 11:45:46.030181');
INSERT INTO "production_records" VALUES(127,1,1,'2026-07-22',2340,'medium','white',2.787963970840146998e+02,1.22845739813555656e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.030184','2026-08-18 11:45:46.030187');
INSERT INTO "production_records" VALUES(128,1,1,'2026-07-22',2336,'medium','brown',2.537160846984826889e+02,1.081879478522154841e+03,6.333333333333333037e+00,0,NULL,'2026-08-18 11:45:46.030190','2026-08-18 11:45:46.030193');
INSERT INTO "production_records" VALUES(129,1,1,'2026-07-23',2483,'small','brown',2.864537416804961367e+02,1.055695545056558103e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.030196','2026-08-18 11:45:46.030199');
INSERT INTO "production_records" VALUES(130,1,1,'2026-07-23',1693,'medium','white',2.694922687958770667e+02,1.043446053810142984e+03,6.166666666666666963e+00,1,NULL,'2026-08-18 11:45:46.030202','2026-08-18 11:45:46.030204');
INSERT INTO "production_records" VALUES(131,1,1,'2026-07-24',1844,'medium','brown',2.92698143083176376e+02,1.124977001657260644e+03,6.333333333333333037e+00,1,NULL,'2026-08-18 11:45:46.030208','2026-08-18 11:45:46.030210');
INSERT INTO "production_records" VALUES(132,1,1,'2026-07-24',2194,'medium','white',2.580885045584404339e+02,1.203720322769560425e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.030213','2026-08-18 11:45:46.030216');
INSERT INTO "production_records" VALUES(133,1,1,'2026-07-25',2362,'large','white',2.996062598488084063e+02,1.127660530889317897e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.030219','2026-08-18 11:45:46.030222');
INSERT INTO "production_records" VALUES(134,1,1,'2026-07-25',2376,'large','brown',2.517780740491986365e+02,1.047731688780554578e+03,7,1,NULL,'2026-08-18 11:45:46.030225','2026-08-18 11:45:46.030228');
INSERT INTO "production_records" VALUES(135,1,1,'2026-07-26',2419,'medium','white',2.58995200650103584e+02,1.121440139135691651e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.030231','2026-08-18 11:45:46.030234');
INSERT INTO "production_records" VALUES(136,1,1,'2026-07-26',1948,'small','white',2.651992626441603421e+02,1.055353866598696868e+03,5.5,0,NULL,'2026-08-18 11:45:46.030237','2026-08-18 11:45:46.030240');
INSERT INTO "production_records" VALUES(137,1,1,'2026-07-27',2482,'small','white',2.929657877910075854e+02,1.119065910165694731e+03,5.5,2,NULL,'2026-08-18 11:45:46.030243','2026-08-18 11:45:46.030246');
INSERT INTO "production_records" VALUES(138,1,1,'2026-07-27',1870,'medium','brown',2.589224209300410849e+02,1.186000553525311261e+03,6.333333333333333037e+00,2,NULL,'2026-08-18 11:45:46.030249','2026-08-18 11:45:46.030252');
INSERT INTO "production_records" VALUES(139,1,1,'2026-07-28',1771,'large','white',2.815923761122560905e+02,1.115466480676762331e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.030255','2026-08-18 11:45:46.030258');
INSERT INTO "production_records" VALUES(140,1,1,'2026-07-28',2081,'large','brown',2.841866678672881221e+02,1.227001634321852179e+03,7,2,NULL,'2026-08-18 11:45:46.030261','2026-08-18 11:45:46.030264');
INSERT INTO "production_records" VALUES(141,1,1,'2026-07-29',2322,'medium','white',2.668926624404517725e+02,1.224295130053923004e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.030267','2026-08-18 11:45:46.030270');
INSERT INTO "production_records" VALUES(142,1,1,'2026-07-29',1740,'medium','brown',2.541848216661234688e+02,1.026575988821397004e+03,6.333333333333333037e+00,2,NULL,'2026-08-18 11:45:46.030273','2026-08-18 11:45:46.030276');
INSERT INTO "production_records" VALUES(143,1,1,'2026-07-30',1762,'large','white',2.862647421056570919e+02,1.023305755044965622e+03,6.833333333333333037e+00,0,NULL,'2026-08-18 11:45:46.030279','2026-08-18 11:45:46.030282');
INSERT INTO "production_records" VALUES(144,1,1,'2026-07-30',2309,'small','white',2.546889813912598016e+02,1.159195601955591428e+03,5.5,2,NULL,'2026-08-18 11:45:46.030285','2026-08-18 11:45:46.030288');
INSERT INTO "production_records" VALUES(145,1,1,'2026-07-31',2415,'large','white',2.62917561692358845e+02,1.132514404352215252e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.030291','2026-08-18 11:45:46.030294');
INSERT INTO "production_records" VALUES(146,1,1,'2026-07-31',1849,'small','white',2.94545113482504803e+02,1.046521656673961161e+03,5.5,1,NULL,'2026-08-18 11:45:46.030297','2026-08-18 11:45:46.030300');
INSERT INTO "production_records" VALUES(147,1,1,'2026-08-01',1682,'small','white',2.675153760325350732e+02,1.058051619493617864e+03,5.5,1,NULL,'2026-08-18 11:45:46.030303','2026-08-18 11:45:46.030306');
INSERT INTO "production_records" VALUES(148,1,1,'2026-08-01',2250,'medium','white',2.571135996416606417e+02,1.103137138447144252e+03,6.166666666666666963e+00,2,NULL,'2026-08-18 11:45:46.030309','2026-08-18 11:45:46.030312');
INSERT INTO "production_records" VALUES(149,1,1,'2026-08-02',2042,'small','white',2.518292897202067878e+02,1.111163954229586352e+03,5.5,0,NULL,'2026-08-18 11:45:46.030315','2026-08-18 11:45:46.030318');
INSERT INTO "production_records" VALUES(150,1,1,'2026-08-02',2168,'small','brown',2.809669544972539371e+02,1.030311998792304849e+03,5.666666666666666963e+00,0,NULL,'2026-08-18 11:45:46.030321','2026-08-18 11:45:46.030324');
INSERT INTO "production_records" VALUES(151,1,1,'2026-08-03',1890,'large','white',2.519839474830618826e+02,1.058700101626958257e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.030327','2026-08-18 11:45:46.030329');
INSERT INTO "production_records" VALUES(152,1,1,'2026-08-03',2090,'small','white',2.572785108231465187e+02,1.139708718844042778e+03,5.5,0,NULL,'2026-08-18 11:45:46.030332','2026-08-18 11:45:46.030335');
INSERT INTO "production_records" VALUES(153,1,1,'2026-08-04',1512,'small','brown',263.577418029585,1.153744729512028698e+03,5.666666666666666963e+00,1,NULL,'2026-08-18 11:45:46.030338','2026-08-18 11:45:46.030341');
INSERT INTO "production_records" VALUES(154,1,1,'2026-08-04',1665,'small','white',2.946828589478195682e+02,1.162928026791744059e+03,5.5,2,NULL,'2026-08-18 11:45:46.030344','2026-08-18 11:45:46.030347');
INSERT INTO "production_records" VALUES(155,1,1,'2026-08-05',2391,'small','brown',2.833581236305936386e+02,1.101798950316456966e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.030350','2026-08-18 11:45:46.030353');
INSERT INTO "production_records" VALUES(156,1,1,'2026-08-05',2475,'small','white',2.958728376943313379e+02,1.134417040970858124e+03,5.5,1,NULL,'2026-08-18 11:45:46.030356','2026-08-18 11:45:46.030359');
INSERT INTO "production_records" VALUES(157,1,1,'2026-08-06',1941,'large','brown',2.880344556521381491e+02,1.190892388346007919e+03,7,2,NULL,'2026-08-18 11:45:46.030362','2026-08-18 11:45:46.030365');
INSERT INTO "production_records" VALUES(158,1,1,'2026-08-06',1709,'large','white',2.75137120572876654e+02,1.234956877096335802e+03,6.833333333333333037e+00,0,NULL,'2026-08-18 11:45:46.030368','2026-08-18 11:45:46.030371');
INSERT INTO "production_records" VALUES(159,1,1,'2026-08-07',2262,'large','brown',2.917654508059248997e+02,1.209264952464159706e+03,7,0,NULL,'2026-08-18 11:45:46.030374','2026-08-18 11:45:46.030377');
INSERT INTO "production_records" VALUES(160,1,1,'2026-08-07',1894,'small','brown',2.572913644086773956e+02,1.221366876069940418e+03,5.666666666666666963e+00,1,NULL,'2026-08-18 11:45:46.030380','2026-08-18 11:45:46.030383');
INSERT INTO "production_records" VALUES(161,1,1,'2026-08-08',1538,'small','brown',2.669615746112775696e+02,1.051771510225305975e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.030386','2026-08-18 11:45:46.030389');
INSERT INTO "production_records" VALUES(162,1,1,'2026-08-08',1667,'large','brown',2.615774205872987749e+02,1.055231394061934906e+03,7,0,NULL,'2026-08-18 11:45:46.030392','2026-08-18 11:45:46.030395');
INSERT INTO "production_records" VALUES(163,1,1,'2026-08-09',2274,'large','white',2.825771044525604339e+02,1.16582785936082314e+03,6.833333333333333037e+00,0,NULL,'2026-08-18 11:45:46.030398','2026-08-18 11:45:46.030401');
INSERT INTO "production_records" VALUES(164,1,1,'2026-08-09',2205,'large','brown',293.597212601855,1.195198497944432802e+03,7,2,NULL,'2026-08-18 11:45:46.030404','2026-08-18 11:45:46.030407');
INSERT INTO "production_records" VALUES(165,1,1,'2026-08-10',2299,'medium','brown',2.648671238482878607e+02,1.130640065146387996e+03,6.333333333333333037e+00,0,NULL,'2026-08-18 11:45:46.030410','2026-08-18 11:45:46.030413');
INSERT INTO "production_records" VALUES(166,1,1,'2026-08-10',2240,'large','white',2.846746828466733632e+02,1.096993249674833805e+03,6.833333333333333037e+00,2,NULL,'2026-08-18 11:45:46.030416','2026-08-18 11:45:46.030419');
INSERT INTO "production_records" VALUES(167,1,1,'2026-08-11',1969,'medium','white',2.551498837893387303e+02,1.033359976357444111e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.030422','2026-08-18 11:45:46.030425');
INSERT INTO "production_records" VALUES(168,1,1,'2026-08-11',2485,'small','brown',2.903361910502408137e+02,1.024632098708862486e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.030428','2026-08-18 11:45:46.030431');
INSERT INTO "production_records" VALUES(169,1,1,'2026-08-12',1532,'small','brown',2.531447191669940366e+02,1.001322129115239023e+03,5.666666666666666963e+00,0,NULL,'2026-08-18 11:45:46.030434','2026-08-18 11:45:46.030437');
INSERT INTO "production_records" VALUES(170,1,1,'2026-08-12',2336,'medium','brown',2.865398536898096041e+02,1.115450384707201465e+03,6.333333333333333037e+00,2,NULL,'2026-08-18 11:45:46.030440','2026-08-18 11:45:46.030443');
INSERT INTO "production_records" VALUES(171,1,1,'2026-08-13',2463,'small','white',2.84899018614446618e+02,1.096004246997578094e+03,5.5,1,NULL,'2026-08-18 11:45:46.030446','2026-08-18 11:45:46.030449');
INSERT INTO "production_records" VALUES(172,1,1,'2026-08-13',1570,'medium','white',2.523263155860144877e+02,1.012159246667336561e+03,6.166666666666666963e+00,2,NULL,'2026-08-18 11:45:46.030452','2026-08-18 11:45:46.030455');
INSERT INTO "production_records" VALUES(173,1,1,'2026-08-14',2361,'medium','brown',2.661689656511492785e+02,1.049723240440925337e+03,6.333333333333333037e+00,0,NULL,'2026-08-18 11:45:46.030458','2026-08-18 11:45:46.030461');
INSERT INTO "production_records" VALUES(174,1,1,'2026-08-14',1803,'small','white',2.697703200974771108e+02,1.005332883883201021e+03,5.5,1,NULL,'2026-08-18 11:45:46.030464','2026-08-18 11:45:46.030467');
INSERT INTO "production_records" VALUES(175,1,1,'2026-08-15',1650,'medium','brown',2.61146978584993633e+02,1.154762160241166156e+03,6.333333333333333037e+00,1,NULL,'2026-08-18 11:45:46.030470','2026-08-18 11:45:46.030472');
INSERT INTO "production_records" VALUES(176,1,1,'2026-08-15',2133,'medium','white',2.633810892771284102e+02,1.218435843231540275e+03,6.166666666666666963e+00,0,NULL,'2026-08-18 11:45:46.030476','2026-08-18 11:45:46.030478');
INSERT INTO "production_records" VALUES(177,1,1,'2026-08-16',2261,'small','white',2.592034065065649315e+02,1.16952504703923023e+03,5.5,2,NULL,'2026-08-18 11:45:46.030481','2026-08-18 11:45:46.030484');
INSERT INTO "production_records" VALUES(178,1,1,'2026-08-16',1646,'small','brown',2.731071455807726238e+02,1.06800514528514077e+03,5.666666666666666963e+00,2,NULL,'2026-08-18 11:45:46.030487','2026-08-18 11:45:46.030490');
INSERT INTO "production_records" VALUES(179,1,1,'2026-08-17',2296,'small','brown',293.696118956879,1.228705593558840747e+03,5.666666666666666963e+00,1,NULL,'2026-08-18 11:45:46.030493','2026-08-18 11:45:46.030496');
INSERT INTO "production_records" VALUES(180,1,1,'2026-08-17',2098,'large','brown',2.696934913075863847e+02,1.105108831286018813e+03,7,0,NULL,'2026-08-18 11:45:46.030499','2026-08-18 11:45:46.030502');
INSERT INTO "production_records" VALUES(181,3,1,'2026-08-18',12969,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.824605','2026-08-18 15:29:36.824611');
INSERT INTO "production_records" VALUES(182,3,1,'2026-08-17',11227,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.828826','2026-08-18 15:29:36.828832');
INSERT INTO "production_records" VALUES(183,3,1,'2026-08-16',11569,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.830230','2026-08-18 15:29:36.830236');
INSERT INTO "production_records" VALUES(184,3,1,'2026-08-15',13160,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.832396','2026-08-18 15:29:36.832401');
INSERT INTO "production_records" VALUES(185,3,1,'2026-08-14',13209,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.833728','2026-08-18 15:29:36.833733');
INSERT INTO "production_records" VALUES(186,3,1,'2026-08-13',11898,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.835171','2026-08-18 15:29:36.835177');
INSERT INTO "production_records" VALUES(187,3,1,'2026-08-12',12493,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.836770','2026-08-18 15:29:36.836774');
INSERT INTO "production_records" VALUES(188,3,1,'2026-08-11',11031,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.838196','2026-08-18 15:29:36.838201');
INSERT INTO "production_records" VALUES(189,3,1,'2026-08-10',12440,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.839408','2026-08-18 15:29:36.839413');
INSERT INTO "production_records" VALUES(190,3,1,'2026-08-09',12212,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.841147','2026-08-18 15:29:36.841151');
INSERT INTO "production_records" VALUES(191,3,1,'2026-08-08',11269,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.842428','2026-08-18 15:29:36.842434');
INSERT INTO "production_records" VALUES(192,3,1,'2026-08-07',11107,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.843819','2026-08-18 15:29:36.843824');
INSERT INTO "production_records" VALUES(193,3,1,'2026-08-06',12337,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.845389','2026-08-18 15:29:36.845394');
INSERT INTO "production_records" VALUES(194,3,1,'2026-08-05',11575,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.846893','2026-08-18 15:29:36.846899');
INSERT INTO "production_records" VALUES(195,3,1,'2026-08-04',12406,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.848230','2026-08-18 15:29:36.848236');
INSERT INTO "production_records" VALUES(196,4,1,'2026-08-18',3562,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.850912','2026-08-18 15:29:36.850917');
INSERT INTO "production_records" VALUES(197,4,1,'2026-08-17',4053,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.852369','2026-08-18 15:29:36.852375');
INSERT INTO "production_records" VALUES(198,4,1,'2026-08-16',3770,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.853598','2026-08-18 15:29:36.853604');
INSERT INTO "production_records" VALUES(199,4,1,'2026-08-15',4009,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.855346','2026-08-18 15:29:36.855350');
INSERT INTO "production_records" VALUES(200,4,1,'2026-08-14',3415,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.856603','2026-08-18 15:29:36.856609');
INSERT INTO "production_records" VALUES(201,4,1,'2026-08-13',3747,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.858176','2026-08-18 15:29:36.858181');
INSERT INTO "production_records" VALUES(202,4,1,'2026-08-12',3586,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.859732','2026-08-18 15:29:36.859736');
INSERT INTO "production_records" VALUES(203,4,1,'2026-08-11',4021,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.861136','2026-08-18 15:29:36.861142');
INSERT INTO "production_records" VALUES(204,4,1,'2026-08-10',3593,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.862388','2026-08-18 15:29:36.862393');
INSERT INTO "production_records" VALUES(205,4,1,'2026-08-09',3816,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.864426','2026-08-18 15:29:36.864431');
INSERT INTO "production_records" VALUES(206,4,1,'2026-08-08',3459,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.865959','2026-08-18 15:29:36.865965');
INSERT INTO "production_records" VALUES(207,4,1,'2026-08-07',3623,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.867425','2026-08-18 15:29:36.867430');
INSERT INTO "production_records" VALUES(208,4,1,'2026-08-06',3882,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.869019','2026-08-18 15:29:36.869023');
INSERT INTO "production_records" VALUES(209,4,1,'2026-08-05',3328,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.870549','2026-08-18 15:29:36.870555');
INSERT INTO "production_records" VALUES(210,4,1,'2026-08-04',3854,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.871775','2026-08-18 15:29:36.871780');
INSERT INTO "production_records" VALUES(211,5,1,'2026-08-18',685,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.874315','2026-08-18 15:29:36.874319');
INSERT INTO "production_records" VALUES(212,5,1,'2026-08-17',675,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.876415','2026-08-18 15:29:36.876421');
INSERT INTO "production_records" VALUES(213,5,1,'2026-08-16',717,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.877670','2026-08-18 15:29:36.877676');
INSERT INTO "production_records" VALUES(214,5,1,'2026-08-15',700,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.879497','2026-08-18 15:29:36.879502');
INSERT INTO "production_records" VALUES(215,5,1,'2026-08-14',711,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.881242','2026-08-18 15:29:36.881251');
INSERT INTO "production_records" VALUES(216,5,1,'2026-08-13',644,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.883348','2026-08-18 15:29:36.883354');
INSERT INTO "production_records" VALUES(217,5,1,'2026-08-12',665,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.885064','2026-08-18 15:29:36.885068');
INSERT INTO "production_records" VALUES(218,5,1,'2026-08-11',707,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.886530','2026-08-18 15:29:36.886535');
INSERT INTO "production_records" VALUES(219,5,1,'2026-08-10',640,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.887790','2026-08-18 15:29:36.887796');
INSERT INTO "production_records" VALUES(220,5,1,'2026-08-09',660,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.889539','2026-08-18 15:29:36.889543');
INSERT INTO "production_records" VALUES(221,5,1,'2026-08-08',748,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.890754','2026-08-18 15:29:36.890760');
INSERT INTO "production_records" VALUES(222,5,1,'2026-08-07',742,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.892157','2026-08-18 15:29:36.892162');
INSERT INTO "production_records" VALUES(223,5,1,'2026-08-06',674,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.893764','2026-08-18 15:29:36.893768');
INSERT INTO "production_records" VALUES(224,5,1,'2026-08-05',762,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.895161','2026-08-18 15:29:36.895166');
INSERT INTO "production_records" VALUES(225,5,1,'2026-08-04',644,NULL,NULL,0,0,NULL,0,'Auto-seeded','2026-08-18 15:29:36.896494','2026-08-18 15:29:36.896504');
CREATE TABLE products (
	id INTEGER NOT NULL, 
	farmer_id INTEGER NOT NULL, 
	farm_id INTEGER NOT NULL, 
	name VARCHAR(150) NOT NULL, 
	description TEXT, 
	size VARCHAR(11) NOT NULL, 
	variety VARCHAR(5) NOT NULL, 
	unit VARCHAR(8) NOT NULL, 
	price NUMERIC(10, 2) NOT NULL, 
	stock INTEGER NOT NULL, 
	location VARCHAR(255), 
	is_available BOOLEAN NOT NULL, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, image_url VARCHAR(500), moderation_status VARCHAR(8) NOT NULL DEFAULT 'pending', 
	PRIMARY KEY (id), 
	FOREIGN KEY(farmer_id) REFERENCES users (id), 
	FOREIGN KEY(farm_id) REFERENCES farms (id)
);
INSERT INTO "products" VALUES(1,1,1,'Fresh Brown Eggs (Small)','Freshly harvested small brown eggs.','small','brown','tray',170,100,NULL,1,'2026-08-18 11:45:45.960398','2026-08-18 11:45:45.960405',NULL,'pending');
INSERT INTO "products" VALUES(2,1,1,'Fresh Brown Eggs (Medium)','Freshly harvested medium brown eggs.','medium','brown','tray',190,300,NULL,1,'2026-08-18 11:45:45.960409','2026-08-18 11:45:45.960412',NULL,'pending');
INSERT INTO "products" VALUES(3,1,1,'Fresh Brown Eggs (Large)','Freshly harvested large brown eggs.','large','brown','tray',210,200,NULL,1,'2026-08-18 11:45:45.960415','2026-08-18 11:45:45.960418',NULL,'pending');
INSERT INTO "products" VALUES(4,1,1,'Fresh White Eggs (Small)','Freshly harvested small white eggs.','small','white','tray',165,120,NULL,1,'2026-08-18 11:45:45.960421','2026-08-18 11:45:45.960424',NULL,'pending');
INSERT INTO "products" VALUES(5,1,1,'Fresh White Eggs (Medium)','Freshly harvested medium white eggs.','medium','white','tray',185,250,NULL,1,'2026-08-18 11:45:45.960428','2026-08-18 11:45:45.960431',NULL,'pending');
INSERT INTO "products" VALUES(6,1,1,'Fresh White Eggs (Large)','Freshly harvested large white eggs.','large','white','tray',205,180,NULL,1,'2026-08-18 11:45:45.960434','2026-08-18 11:45:45.960437',NULL,'pending');
CREATE TABLE sales_records (
	id INTEGER NOT NULL, 
	farm_id INTEGER NOT NULL, 
	user_id INTEGER NOT NULL, 
	sale_date DATE NOT NULL, 
	quantity_sold INTEGER NOT NULL, 
	price_per_egg NUMERIC(10, 2) NOT NULL, 
	total_revenue NUMERIC(12, 2) NOT NULL, 
	buyer_name VARCHAR(255), 
	notes TEXT, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(farm_id) REFERENCES farms (id), 
	FOREIGN KEY(user_id) REFERENCES users (id)
);
INSERT INTO "sales_records" VALUES(1,1,1,'2026-06-08',570,6.333333333333333037e+00,3610,'Maria Reyes',NULL,'2026-06-08 09:00:00.000000','2026-08-18 11:45:46.045133');
INSERT INTO "sales_records" VALUES(2,1,1,'2026-06-16',570,6.166666666666666963e+00,3515,'Maria Reyes',NULL,'2026-06-16 18:00:00.000000','2026-08-18 11:45:46.047754');
INSERT INTO "sales_records" VALUES(3,1,1,'2026-06-13',1380,6.833333333333333037e+00,9430,'Maria Reyes',NULL,'2026-06-13 08:00:00.000000','2026-08-18 11:45:46.049073');
INSERT INTO "sales_records" VALUES(4,1,1,'2026-08-03',1410,7,9870,'Maria Reyes',NULL,'2026-08-03 09:00:00.000000','2026-08-18 11:45:46.050385');
INSERT INTO "sales_records" VALUES(5,1,1,'2026-06-24',1200,6.833333333333333037e+00,8200,'Maria Reyes',NULL,'2026-06-24 14:00:00.000000','2026-08-18 11:45:46.051775');
INSERT INTO "sales_records" VALUES(6,1,1,'2026-08-01',1440,7,10080,'Maria Reyes',NULL,'2026-08-01 09:00:00.000000','2026-08-18 11:45:46.053434');
INSERT INTO "sales_records" VALUES(7,1,1,'2026-05-25',1410,5.666666666666666963e+00,7990,'Maria Reyes',NULL,'2026-05-25 08:00:00.000000','2026-08-18 11:45:46.054833');
INSERT INTO "sales_records" VALUES(8,1,1,'2026-06-20',1440,5.666666666666666963e+00,8160,'Maria Reyes',NULL,'2026-06-20 12:00:00.000000','2026-08-18 11:45:46.056156');
INSERT INTO "sales_records" VALUES(9,1,1,'2026-07-26',990,6.333333333333333037e+00,6270,'Maria Reyes',NULL,'2026-07-26 14:00:00.000000','2026-08-18 11:45:46.057449');
INSERT INTO "sales_records" VALUES(10,1,1,'2026-08-09',1050,6.833333333333333037e+00,7175,'Maria Reyes',NULL,'2026-08-09 10:00:00.000000','2026-08-18 11:45:46.058755');
INSERT INTO "sales_records" VALUES(11,1,1,'2026-06-21',690,6.833333333333333037e+00,4715,'Maria Reyes',NULL,'2026-06-21 14:00:00.000000','2026-08-18 11:45:46.060110');
INSERT INTO "sales_records" VALUES(12,1,1,'2026-08-14',150,6.833333333333333037e+00,1025,'Maria Reyes',NULL,'2026-08-14 11:00:00.000000','2026-08-18 11:45:46.061398');
INSERT INTO "sales_records" VALUES(13,1,1,'2026-06-10',1290,6.166666666666666963e+00,7955,'Maria Reyes',NULL,'2026-06-10 13:00:00.000000','2026-08-18 11:45:46.062699');
INSERT INTO "sales_records" VALUES(14,1,1,'2026-08-02',840,7,5880,'Maria Reyes',NULL,'2026-08-02 12:00:00.000000','2026-08-18 11:45:46.064040');
INSERT INTO "sales_records" VALUES(15,1,1,'2026-05-28',900,6.166666666666666963e+00,5550,'Maria Reyes',NULL,'2026-05-28 10:00:00.000000','2026-08-18 11:45:46.065320');
INSERT INTO "sales_records" VALUES(16,1,1,'2026-07-11',870,6.833333333333333037e+00,5945,'Maria Reyes',NULL,'2026-07-11 16:00:00.000000','2026-08-18 11:45:46.066618');
INSERT INTO "sales_records" VALUES(17,1,1,'2026-07-03',1350,7,9450,'Maria Reyes',NULL,'2026-07-03 13:00:00.000000','2026-08-18 11:45:46.067926');
INSERT INTO "sales_records" VALUES(18,1,1,'2026-07-30',1410,5.5,7755,'Maria Reyes',NULL,'2026-07-30 14:00:00.000000','2026-08-18 11:45:46.069428');
INSERT INTO "sales_records" VALUES(19,1,1,'2026-08-04',180,5.666666666666666963e+00,1020,'Maria Reyes',NULL,'2026-08-04 09:00:00.000000','2026-08-18 11:45:46.070894');
INSERT INTO "sales_records" VALUES(20,1,1,'2026-06-30',1110,6.833333333333333037e+00,7585,'Maria Reyes',NULL,'2026-06-30 13:00:00.000000','2026-08-18 11:45:46.072240');
INSERT INTO "sales_records" VALUES(21,1,1,'2026-07-02',480,6.833333333333333037e+00,3280,'Maria Reyes',NULL,'2026-07-02 12:00:00.000000','2026-08-18 11:45:46.073581');
INSERT INTO "sales_records" VALUES(22,1,1,'2026-05-24',600,5.5,3300,'Maria Reyes',NULL,'2026-05-24 16:00:00.000000','2026-08-18 11:45:46.074870');
INSERT INTO "sales_records" VALUES(23,1,1,'2026-08-09',1410,6.166666666666666963e+00,8695,'Maria Reyes',NULL,'2026-08-09 08:00:00.000000','2026-08-18 11:45:46.076150');
INSERT INTO "sales_records" VALUES(24,1,1,'2026-05-30',1200,7,8400,'Maria Reyes',NULL,'2026-05-30 15:00:00.000000','2026-08-18 11:45:46.077425');
INSERT INTO "sales_records" VALUES(25,1,1,'2026-07-26',1350,6.833333333333333037e+00,9225,'Maria Reyes',NULL,'2026-07-26 13:00:00.000000','2026-08-18 11:45:46.078721');
INSERT INTO "sales_records" VALUES(26,1,1,'2026-06-25',840,5.5,4620,'Maria Reyes',NULL,'2026-06-25 08:00:00.000000','2026-08-18 11:45:46.080966');
INSERT INTO "sales_records" VALUES(27,1,1,'2026-06-02',210,6.333333333333333037e+00,1330,'Maria Reyes',NULL,'2026-06-02 09:00:00.000000','2026-08-18 11:45:46.082247');
INSERT INTO "sales_records" VALUES(28,1,1,'2026-05-25',1350,5.666666666666666963e+00,7650,'Maria Reyes',NULL,'2026-05-25 17:00:00.000000','2026-08-18 11:45:46.083519');
INSERT INTO "sales_records" VALUES(29,1,1,'2026-07-08',1380,5.666666666666666963e+00,7820,'Maria Reyes',NULL,'2026-07-08 12:00:00.000000','2026-08-18 11:45:46.085182');
INSERT INTO "sales_records" VALUES(30,1,1,'2026-06-21',690,6.833333333333333037e+00,4715,'Maria Reyes',NULL,'2026-06-21 14:00:00.000000','2026-08-18 11:45:46.086667');
INSERT INTO "sales_records" VALUES(31,1,1,'2026-06-23',690,5.666666666666666963e+00,3910,'Maria Reyes',NULL,'2026-06-23 09:00:00.000000','2026-08-18 11:45:46.087983');
INSERT INTO "sales_records" VALUES(32,1,1,'2026-05-23',1380,6.166666666666666963e+00,8510,'Maria Reyes',NULL,'2026-05-23 09:00:00.000000','2026-08-18 11:45:46.089301');
INSERT INTO "sales_records" VALUES(33,1,1,'2026-07-14',390,5.5,2145,'Maria Reyes',NULL,'2026-07-14 08:00:00.000000','2026-08-18 11:45:46.090602');
INSERT INTO "sales_records" VALUES(34,1,1,'2026-06-13',1380,6.333333333333333037e+00,8740,'Maria Reyes',NULL,'2026-06-13 14:00:00.000000','2026-08-18 11:45:46.091878');
INSERT INTO "sales_records" VALUES(35,1,1,'2026-07-21',1470,5.5,8085,'Maria Reyes',NULL,'2026-07-21 17:00:00.000000','2026-08-18 11:45:46.093174');
INSERT INTO "sales_records" VALUES(36,1,1,'2026-07-22',990,5.5,5445,'Maria Reyes',NULL,'2026-07-22 15:00:00.000000','2026-08-18 11:45:46.094467');
INSERT INTO "sales_records" VALUES(37,1,1,'2026-08-03',510,5.5,2805,'Maria Reyes',NULL,'2026-08-03 08:00:00.000000','2026-08-18 11:45:46.095745');
INSERT INTO "sales_records" VALUES(38,1,1,'2026-05-29',780,6.166666666666666963e+00,4810,'Maria Reyes',NULL,'2026-05-29 12:00:00.000000','2026-08-18 11:45:46.097036');
INSERT INTO "sales_records" VALUES(39,1,1,'2026-06-07',1320,6.166666666666666963e+00,8140,'Maria Reyes',NULL,'2026-06-07 13:00:00.000000','2026-08-18 11:45:46.098329');
INSERT INTO "sales_records" VALUES(40,1,1,'2026-08-13',1380,5.5,7590,'Maria Reyes',NULL,'2026-08-13 15:00:00.000000','2026-08-18 11:45:46.099607');
INSERT INTO "sales_records" VALUES(41,1,1,'2026-06-02',330,5.666666666666666963e+00,1870,'Maria Reyes',NULL,'2026-06-02 08:00:00.000000','2026-08-18 11:45:46.101003');
INSERT INTO "sales_records" VALUES(42,1,1,'2026-06-21',870,5.666666666666666963e+00,4930,'Maria Reyes',NULL,'2026-06-21 16:00:00.000000','2026-08-18 11:45:46.102982');
INSERT INTO "sales_records" VALUES(43,1,1,'2026-07-15',1260,7,8820,'Maria Reyes',NULL,'2026-07-15 13:00:00.000000','2026-08-18 11:45:46.104422');
INSERT INTO "sales_records" VALUES(44,1,1,'2026-08-04',630,5.666666666666666963e+00,3570,'Maria Reyes',NULL,'2026-08-04 11:00:00.000000','2026-08-18 11:45:46.105710');
INSERT INTO "sales_records" VALUES(45,1,1,'2026-07-23',870,6.166666666666666963e+00,5365,'Maria Reyes',NULL,'2026-07-23 11:00:00.000000','2026-08-18 11:45:46.107030');
INSERT INTO "sales_records" VALUES(46,1,1,'2026-07-13',1410,6.833333333333333037e+00,9635,'Maria Reyes',NULL,'2026-07-13 09:00:00.000000','2026-08-18 11:45:46.108337');
INSERT INTO "sales_records" VALUES(47,1,1,'2026-06-30',600,6.166666666666666963e+00,3700,'Maria Reyes',NULL,'2026-06-30 11:00:00.000000','2026-08-18 11:45:46.109620');
INSERT INTO "sales_records" VALUES(48,1,1,'2026-07-30',1260,6.166666666666666963e+00,7770,'Maria Reyes',NULL,'2026-07-30 15:00:00.000000','2026-08-18 11:45:46.110915');
INSERT INTO "sales_records" VALUES(49,1,1,'2026-08-03',1470,7,10290,'Maria Reyes',NULL,'2026-08-03 11:00:00.000000','2026-08-18 11:45:46.112215');
INSERT INTO "sales_records" VALUES(50,1,1,'2026-07-14',480,6.166666666666666963e+00,2960,'Maria Reyes',NULL,'2026-07-14 17:00:00.000000','2026-08-18 11:45:46.113554');
INSERT INTO "sales_records" VALUES(51,1,1,'2026-05-24',1470,6.333333333333333037e+00,9310,'Maria Reyes',NULL,'2026-05-24 10:00:00.000000','2026-08-18 11:45:46.114843');
INSERT INTO "sales_records" VALUES(52,1,1,'2026-07-14',540,6.333333333333333037e+00,3420,'Maria Reyes',NULL,'2026-07-14 09:00:00.000000','2026-08-18 11:45:46.116162');
INSERT INTO "sales_records" VALUES(53,1,1,'2026-05-21',1110,5.666666666666666963e+00,6290,'Maria Reyes',NULL,'2026-05-21 16:00:00.000000','2026-08-18 11:45:46.117472');
INSERT INTO "sales_records" VALUES(54,1,1,'2026-08-04',390,5.5,2145,'Maria Reyes',NULL,'2026-08-04 09:00:00.000000','2026-08-18 11:45:46.118835');
INSERT INTO "sales_records" VALUES(55,1,1,'2026-07-23',720,6.166666666666666963e+00,4440,'Maria Reyes',NULL,'2026-07-23 18:00:00.000000','2026-08-18 11:45:46.120321');
INSERT INTO "sales_records" VALUES(56,1,1,'2026-06-16',660,6.166666666666666963e+00,4070,'Maria Reyes',NULL,'2026-06-16 08:00:00.000000','2026-08-18 11:45:46.121652');
INSERT INTO "sales_records" VALUES(57,1,1,'2026-06-08',750,5.5,4125,'Maria Reyes',NULL,'2026-06-08 17:00:00.000000','2026-08-18 11:45:46.122976');
INSERT INTO "sales_records" VALUES(58,1,1,'2026-07-01',960,5.666666666666666963e+00,5440,'Maria Reyes',NULL,'2026-07-01 18:00:00.000000','2026-08-18 11:45:46.124277');
INSERT INTO "sales_records" VALUES(59,1,1,'2026-07-18',840,6.833333333333333037e+00,5740,'Maria Reyes',NULL,'2026-07-18 09:00:00.000000','2026-08-18 11:45:46.125558');
INSERT INTO "sales_records" VALUES(60,1,1,'2026-07-01',1140,6.333333333333333037e+00,7220,'Maria Reyes',NULL,'2026-07-01 13:00:00.000000','2026-08-18 11:45:46.126848');
INSERT INTO "sales_records" VALUES(61,1,1,'2026-08-09',1140,6.333333333333333037e+00,7220,'Maria Reyes',NULL,'2026-08-09 17:00:00.000000','2026-08-18 11:45:46.128151');
INSERT INTO "sales_records" VALUES(62,1,1,'2026-07-26',840,6.833333333333333037e+00,5740,'Maria Reyes',NULL,'2026-07-26 11:00:00.000000','2026-08-18 11:45:46.129428');
INSERT INTO "sales_records" VALUES(63,1,1,'2026-05-22',1500,6.166666666666666963e+00,9250,'Maria Reyes',NULL,'2026-05-22 12:00:00.000000','2026-08-18 11:45:46.130721');
INSERT INTO "sales_records" VALUES(64,1,1,'2026-05-28',990,5.5,5445,'Maria Reyes',NULL,'2026-05-28 10:00:00.000000','2026-08-18 11:45:46.132009');
INSERT INTO "sales_records" VALUES(65,1,1,'2026-07-27',1020,6.833333333333333037e+00,6970,'Maria Reyes',NULL,'2026-07-27 11:00:00.000000','2026-08-18 11:45:46.134307');
INSERT INTO "sales_records" VALUES(66,1,1,'2026-07-25',690,6.166666666666666963e+00,4255,'Maria Reyes',NULL,'2026-07-25 13:00:00.000000','2026-08-18 11:45:46.135688');
INSERT INTO "sales_records" VALUES(67,1,1,'2026-08-13',450,7,3150,'Maria Reyes',NULL,'2026-08-13 10:00:00.000000','2026-08-18 11:45:46.137135');
INSERT INTO "sales_records" VALUES(68,1,1,'2026-06-27',1080,6.333333333333333037e+00,6840,'Maria Reyes',NULL,'2026-06-27 18:00:00.000000','2026-08-18 11:45:46.138222');
INSERT INTO "sales_records" VALUES(69,3,1,'2026-08-18',19906,6.947241256811951259e+00,1.382917844580987002e+05,'Local Market','Auto-seeded','2026-08-18 15:29:36.826827','2026-08-18 15:29:36.826833');
INSERT INTO "sales_records" VALUES(70,3,1,'2026-08-16',20366,7.388202698355833319e+00,1.504681361547149135e+05,'Local Market','Auto-seeded','2026-08-18 15:29:36.830504','2026-08-18 15:29:36.830509');
INSERT INTO "sales_records" VALUES(71,3,1,'2026-08-14',23871,7.739251474722488311e+00,1.847436719531005074e+05,'Local Market','Auto-seeded','2026-08-18 15:29:36.833994','2026-08-18 15:29:36.833998');
INSERT INTO "sales_records" VALUES(72,3,1,'2026-08-12',20355,7.435239339673168857e+00,1.513442967590473418e+05,'Local Market','Auto-seeded','2026-08-18 15:29:36.837000','2026-08-18 15:29:36.837005');
INSERT INTO "sales_records" VALUES(73,3,1,'2026-08-10',18966,7.718607766757884292e+00,1.463911149043300248e+05,'Local Market','Auto-seeded','2026-08-18 15:29:36.839650','2026-08-18 15:29:36.839655');
INSERT INTO "sales_records" VALUES(74,3,1,'2026-08-08',21480,7.41624473990212163e+00,1.593009370130975731e+05,'Local Market','Auto-seeded','2026-08-18 15:29:36.842672','2026-08-18 15:29:36.842677');
INSERT INTO "sales_records" VALUES(75,3,1,'2026-08-06',18730,8.06935383234404,1.511389972798038797e+05,'Local Market','Auto-seeded','2026-08-18 15:29:36.845612','2026-08-18 15:29:36.845617');
INSERT INTO "sales_records" VALUES(76,3,1,'2026-08-04',19399,7.62026877832602878e+00,1.478255940307466372e+05,'Local Market','Auto-seeded','2026-08-18 15:29:36.848507','2026-08-18 15:29:36.848512');
INSERT INTO "sales_records" VALUES(77,4,1,'2026-08-18',6581,7.658457682989329385e+00,5.040031001175277924e+04,'Local Market','Auto-seeded','2026-08-18 15:29:36.851147','2026-08-18 15:29:36.851152');
INSERT INTO "sales_records" VALUES(78,4,1,'2026-08-16',7047,7.69089801903195358e+00,5.419775834011817643e+04,'Local Market','Auto-seeded','2026-08-18 15:29:36.853844','2026-08-18 15:29:36.853849');
INSERT INTO "sales_records" VALUES(79,4,1,'2026-08-14',5862,6.571160963263235288e+00,3.852014556664908742e+04,'Local Market','Auto-seeded','2026-08-18 15:29:36.856846','2026-08-18 15:29:36.856851');
INSERT INTO "sales_records" VALUES(80,4,1,'2026-08-12',7104,6.897204248896205315e+00,4.899773898415864096e+04,'Local Market','Auto-seeded','2026-08-18 15:29:36.859956','2026-08-18 15:29:36.859960');
INSERT INTO "sales_records" VALUES(81,4,1,'2026-08-10',7288,7.828316791760379089e+00,5.705277277834964479e+04,'Local Market','Auto-seeded','2026-08-18 15:29:36.862647','2026-08-18 15:29:36.862654');
INSERT INTO "sales_records" VALUES(82,4,1,'2026-08-08',6513,7.595824823914703038e+00,4.94716070781564631e+04,'Local Market','Auto-seeded','2026-08-18 15:29:36.866239','2026-08-18 15:29:36.866245');
INSERT INTO "sales_records" VALUES(83,4,1,'2026-08-06',7008,7.068251715552213099e+00,4.953430802258991026e+04,'Local Market','Auto-seeded','2026-08-18 15:29:36.869245','2026-08-18 15:29:36.869250');
INSERT INTO "sales_records" VALUES(84,4,1,'2026-08-04',7318,7.13491086854649,5.221327773602321395e+04,'Local Market','Auto-seeded','2026-08-18 15:29:36.872022','2026-08-18 15:29:36.872027');
INSERT INTO "sales_records" VALUES(85,5,1,'2026-08-18',1247,7.706342283410175576e+00,9609.80882741249,'Local Market','Auto-seeded','2026-08-18 15:29:36.875230','2026-08-18 15:29:36.875235');
INSERT INTO "sales_records" VALUES(86,5,1,'2026-08-16',1193,6.90651294936503,8.23946994859248116e+03,'Local Market','Auto-seeded','2026-08-18 15:29:36.877977','2026-08-18 15:29:36.877982');
INSERT INTO "sales_records" VALUES(87,5,1,'2026-08-14',1212,8.463479242184011042e+00,1.025773684152702116e+04,'Local Market','Auto-seeded','2026-08-18 15:29:36.881672','2026-08-18 15:29:36.881680');
INSERT INTO "sales_records" VALUES(88,5,1,'2026-08-12',1182,7.656494498319629471e+00,9.049976497013802145e+03,'Local Market','Auto-seeded','2026-08-18 15:29:36.885295','2026-08-18 15:29:36.885300');
INSERT INTO "sales_records" VALUES(89,5,1,'2026-08-10',1208,7.900513057535112794e+00,9.54381977350241686e+03,'Local Market','Auto-seeded','2026-08-18 15:29:36.888038','2026-08-18 15:29:36.888043');
INSERT INTO "sales_records" VALUES(90,5,1,'2026-08-08',1152,7.435131696260093292e+00,8.565271714091628383e+03,'Local Market','Auto-seeded','2026-08-18 15:29:36.891017','2026-08-18 15:29:36.891022');
INSERT INTO "sales_records" VALUES(91,5,1,'2026-08-06',1290,7.721347447447814538e+00,9960.53820720768,'Local Market','Auto-seeded','2026-08-18 15:29:36.893990','2026-08-18 15:29:36.893995');
INSERT INTO "sales_records" VALUES(92,5,1,'2026-08-04',1213,8.271115913474206494e+00,1.003286360304421215e+04,'Local Market','Auto-seeded','2026-08-18 15:29:36.896926','2026-08-18 15:29:36.896936');
CREATE TABLE users (
	id INTEGER NOT NULL, 
	username VARCHAR(64) NOT NULL, 
	email VARCHAR(120) NOT NULL, 
	password_hash VARCHAR(256) NOT NULL, 
	role VARCHAR(13) NOT NULL, 
	first_name VARCHAR(64), 
	last_name VARCHAR(64), 
	phone VARCHAR(20), 
	address VARCHAR(200), 
	landmark VARCHAR(255), 
	is_active BOOLEAN NOT NULL, 
	online_status BOOLEAN NOT NULL, 
	last_seen DATETIME, 
	created_at DATETIME NOT NULL, 
	updated_at DATETIME NOT NULL, 
	PRIMARY KEY (id)
);
INSERT INTO "users" VALUES(1,'jdelacruz','farmer@poultryconnect.com','scrypt:32768:8:1$fOW9YGfvPLHlRR8k$f7bb7a511c24e2b2dfc25ea9ad8d451c2f51cf77e0619ce2ba1df27ba8e4355b786114d88ccbdaa1bea95e9a90e41b30bfebc09732abe634e102221c9a7bd054','farmer','Juan','Dela Cruz','09171234567',NULL,NULL,1,1,'2026-08-21 18:01:51.465715','2026-08-18 11:45:45.917860','2026-08-21 18:01:51.467594');
INSERT INTO "users" VALUES(2,'mreyes','buyer@poultryconnect.com','scrypt:32768:8:1$fIK1vfTjontFTo8r$2dd900357420e0f6ab1067a2c1fabb1bcc08dc8879694be5a744f9e401c1b44abf2e23e5965cba71d84cf9b8bccabb5adc10291d35ab4f1859a69a827d56e96e','buyer','Maria','Reyes','09189876543',NULL,NULL,1,1,'2026-08-21 18:15:20.044639','2026-08-18 11:45:45.917881','2026-08-21 18:15:20.045438');
INSERT INTO "users" VALUES(3,'testfarmer','testfarmer@example.com','scrypt:32768:8:1$B9sWyHY1csN0Ac2K$6f64024bbd1b04d79bad12d124ade858ab85dfd509f00157c0cbdd62d7d6b077fdd45ec1b14b13c4ac4508f37dfa19bde6f54cacee087ae898eb0e11598e763c','farmer','Test','Farmer',NULL,NULL,NULL,0,1,'2026-08-18 12:46:44.259544','2026-08-18 12:41:40.384640','2026-08-21 18:13:42.648431');
INSERT INTO "users" VALUES(4,'admin','admin@poultryconnect.com','scrypt:32768:8:1$anWqpM7jDeQlXTA3$bf762ba4b948be942e1711b5f698d4ba29f18e974bdcad757db882638e0c0f68a79c34af53a30f5110ee80e6aaf18fad2adfcf53de4276b4f9c6f4bd183711dd','admin','System','Administrator',NULL,NULL,NULL,1,0,'2026-08-21 18:15:09.214254','2026-08-21 15:02:38.236813','2026-08-21 18:15:09.214995');
CREATE UNIQUE INDEX ix_users_email ON users (email);
CREATE UNIQUE INDEX ix_users_username ON users (username);
CREATE INDEX ix_users_role ON users (role);
CREATE INDEX ix_farms_farmer_id ON farms (farmer_id);
CREATE INDEX ix_orders_status ON orders (status);
CREATE INDEX ix_orders_buyer_id ON orders (buyer_id);
CREATE INDEX ix_conversations_farmer_id ON conversations (farmer_id);
CREATE INDEX ix_conversations_participant_id ON conversations (participant_id);
CREATE INDEX ix_notifications_is_read ON notifications (is_read);
CREATE INDEX ix_notifications_user_id ON notifications (user_id);
CREATE INDEX ix_production_records_record_date ON production_records (record_date);
CREATE INDEX ix_production_records_user_id ON production_records (user_id);
CREATE INDEX ix_production_records_farm_id ON production_records (farm_id);
CREATE INDEX ix_expenses_farm_id ON expenses (farm_id);
CREATE INDEX ix_expenses_category ON expenses (category);
CREATE INDEX ix_expenses_user_id ON expenses (user_id);
CREATE INDEX ix_expenses_expense_date ON expenses (expense_date);
CREATE INDEX ix_sales_records_farm_id ON sales_records (farm_id);
CREATE INDEX ix_sales_records_sale_date ON sales_records (sale_date);
CREATE INDEX ix_sales_records_user_id ON sales_records (user_id);
CREATE INDEX ix_products_variety ON products (variety);
CREATE INDEX ix_products_size ON products (size);
CREATE INDEX ix_products_is_available ON products (is_available);
CREATE INDEX ix_products_farm_id ON products (farm_id);
CREATE INDEX ix_products_farmer_id ON products (farmer_id);
CREATE INDEX ix_messages_is_seen ON messages (is_seen);
CREATE INDEX ix_messages_sender_id ON messages (sender_id);
CREATE INDEX ix_messages_sent_at ON messages (sent_at);
CREATE INDEX ix_messages_receiver_id ON messages (receiver_id);
CREATE INDEX ix_messages_conversation_id ON messages (conversation_id);
CREATE INDEX ix_order_items_order_id ON order_items (order_id);
CREATE INDEX ix_order_items_product_id ON order_items (product_id);
CREATE INDEX ix_flock_history_date ON flock_history (date);
CREATE INDEX ix_flock_history_farm_id ON flock_history (farm_id);
CREATE INDEX ix_feed_records_farm_id ON feed_records (farm_id);
CREATE INDEX ix_feed_records_record_date ON feed_records (record_date);
CREATE INDEX ix_feed_records_user_id ON feed_records (user_id);
CREATE INDEX ix_flock_history_user_id ON flock_history (user_id);
CREATE INDEX ix_mortality_records_farm_id ON mortality_records (farm_id);
CREATE INDEX ix_mortality_records_record_date ON mortality_records (record_date);
CREATE INDEX ix_mortality_records_user_id ON mortality_records (user_id);
CREATE UNIQUE INDEX ix_farmer_verifications_farmer_id ON farmer_verifications (farmer_id);
CREATE INDEX ix_farmer_verifications_status ON farmer_verifications (status);
CREATE INDEX ix_content_moderations_product_id ON content_moderations (product_id);
CREATE INDEX ix_content_moderations_status ON content_moderations (status);
CREATE INDEX ix_content_moderations_uploader_id ON content_moderations (uploader_id);
CREATE INDEX ix_buyer_feedback_order_id ON buyer_feedback (order_id);
CREATE INDEX ix_buyer_feedback_buyer_id ON buyer_feedback (buyer_id);
DELETE FROM "sqlite_sequence";
COMMIT;
