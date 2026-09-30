CREATE DATABASE IF NOT EXISTS `poultryconnect`;
USE `poultryconnect`;

SET foreign_key_checks = 0;

CREATE TABLE alembic_version (
	version_num VARCHAR(32) NOT NULL, 
	CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);
INSERT INTO `alembic_version` VALUES('eaa7a095e8bd');
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
INSERT INTO `buyer_feedback` VALUES(1,2,10,'product',5,'The eggs were perfectly fresh and delivery was fast!','Fresh eggs and fast delivery','Positive','[`eggs`, `fresh`, `delivery`, `fast`]','2026-08-21 16:23:49.075988','2026-08-21 16:41:04.789460',NULL,1);
INSERT INTO `buyer_feedback` VALUES(2,2,41,'delivery',2,'mabagal yun delivery','slow delivery','Negative','[`mabagal`, `delivery`, `slow delivery`]','2026-08-21 16:23:49.080015','2026-08-21 16:41:04.796157',NULL,1);
INSERT INTO `buyer_feedback` VALUES(3,2,55,'delivery',5,'fast delivery','fast delivery','Positive','[`fast`, `delivery`]','2026-08-21 16:23:49.081084','2026-08-21 16:41:04.797508',NULL,1);
INSERT INTO `buyer_feedback` VALUES(4,2,67,'website',4,'mabilis naman',NULL,'Positive','[`mabilis`, `fast`, `delivery`]','2026-08-21 17:45:53.392759','2026-08-21 17:45:53.392770',NULL,NULL);
INSERT INTO `buyer_feedback` VALUES(5,2,67,'product',5,'okay lang',NULL,'Neutral','[`okay`, `lang`, `average`, `acceptable`]','2026-08-21 17:46:16.313289','2026-08-21 17:46:16.313296',6,1);
INSERT INTO `buyer_feedback` VALUES(6,2,67,'delivery',4,'mabilis',NULL,'Positive','[`mabilis`, `fast`, `delivery`]','2026-08-21 17:46:16.313301','2026-08-21 17:46:16.313304',NULL,1);
INSERT INTO `buyer_feedback` VALUES(7,2,4,'website',3,'',NULL,NULL,NULL,'2026-08-21 17:48:36.042077','2026-08-21 17:48:36.042084',NULL,NULL);
INSERT INTO `buyer_feedback` VALUES(8,2,4,'product',5,'',NULL,NULL,NULL,'2026-08-21 17:48:36.049721','2026-08-21 17:48:36.049727',3,1);
INSERT INTO `buyer_feedback` VALUES(9,2,4,'delivery',4,'',NULL,NULL,NULL,'2026-08-21 17:48:36.049732','2026-08-21 17:48:36.049735',NULL,1);
INSERT INTO `buyer_feedback` VALUES(10,2,40,'website',4,'',NULL,NULL,NULL,'2026-08-21 17:48:53.645206','2026-08-21 17:48:53.645216',NULL,NULL);
INSERT INTO `buyer_feedback` VALUES(11,2,40,'product',5,'',NULL,NULL,NULL,'2026-08-21 17:48:53.648598','2026-08-21 17:48:53.648608',5,1);
INSERT INTO `buyer_feedback` VALUES(12,2,40,'delivery',4,'',NULL,NULL,NULL,'2026-08-21 17:48:53.648616','2026-08-21 17:48:53.648621',NULL,1);
INSERT INTO `buyer_feedback` VALUES(13,2,68,'website',5,'',NULL,NULL,NULL,'2026-08-21 18:24:12.966509','2026-08-21 18:24:12.966517',NULL,NULL);
INSERT INTO `buyer_feedback` VALUES(14,2,68,'product',5,'',NULL,NULL,NULL,'2026-08-21 18:24:12.972049','2026-08-21 18:24:12.972060',5,1);
INSERT INTO `buyer_feedback` VALUES(15,2,68,'delivery',5,'',NULL,NULL,NULL,'2026-08-21 18:24:12.972067','2026-08-21 18:24:12.972073',NULL,1);
INSERT INTO `buyer_feedback` VALUES(16,2,NULL,'product',5,'Napaka-fresh ng mga itlog at mabilis ang delivery!','Fast Delivery','Positive','[`napakafresh`, `itlog`, `mabilis`, `delivery`]','2026-09-21 16:21:27.342896','2026-09-21 16:21:27.342902',NULL,NULL);
INSERT INTO `buyer_feedback` VALUES(17,2,NULL,'product',5,'Napaka-fresh ng mga itlog at mabilis ang delivery!','Fast Delivery','Positive','[`napakafresh`, `itlog`, `mabilis`, `delivery`]','2026-09-21 16:21:46.311696','2026-09-21 16:21:46.311702',NULL,NULL);
INSERT INTO `buyer_feedback` VALUES(18,2,NULL,'product',5,'Napaka-fresh ng mga itlog at mabilis ang delivery!','Fast Delivery','Positive','[`napakafresh`, `itlog`, `mabilis`, `delivery`]','2026-09-21 16:22:33.991848','2026-09-21 16:22:33.991854',NULL,NULL);
INSERT INTO `buyer_feedback` VALUES(19,2,NULL,'product',5,'Napaka-fresh ng mga itlog at mabilis ang delivery!','Fast Delivery','Positive','[`napakafresh`, `itlog`, `mabilis`, `delivery`]','2026-09-21 16:22:57.874598','2026-09-21 16:22:57.874604',NULL,NULL);
INSERT INTO `buyer_feedback` VALUES(20,3,12,'website',5,'',NULL,NULL,NULL,'2026-09-30 06:14:14.682226','2026-09-30 06:14:14.682233',NULL,NULL);
INSERT INTO `buyer_feedback` VALUES(21,3,12,'product',5,'',NULL,NULL,NULL,'2026-09-30 06:14:14.687165','2026-09-30 06:14:14.687172',2,2);
INSERT INTO `buyer_feedback` VALUES(22,3,12,'delivery',5,'',NULL,NULL,NULL,'2026-09-30 06:14:14.687176','2026-09-30 06:14:14.687179',NULL,2);
INSERT INTO `buyer_feedback` VALUES(23,3,40,'website',5,'',NULL,NULL,NULL,'2026-09-30 06:17:23.965829','2026-09-30 06:17:23.965835',NULL,NULL);
INSERT INTO `buyer_feedback` VALUES(24,3,40,'product',5,'',NULL,NULL,NULL,'2026-09-30 06:17:23.969609','2026-09-30 06:17:23.969615',3,2);
INSERT INTO `buyer_feedback` VALUES(25,3,40,'delivery',5,'',NULL,NULL,NULL,'2026-09-30 06:17:23.969619','2026-09-30 06:17:23.969622',NULL,2);
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
INSERT INTO `expenses` VALUES(1,1,2,'2026-07-01','feed','one_time',NULL,1.633750442152096547e+04,'Weekly feed supply','2026-09-29 07:50:21.594096','2026-09-29 07:50:21.594110');
INSERT INTO `expenses` VALUES(2,1,2,'2026-07-01','labor','one_time',NULL,1.087758538954356663e+04,'Farm hand wages','2026-09-29 07:50:21.594121','2026-09-29 07:50:21.594128');
INSERT INTO `expenses` VALUES(3,1,2,'2026-07-01','utilities','one_time',NULL,5.876594949638183608e+03,'Electricity and water bill','2026-09-29 07:50:21.594137','2026-09-29 07:50:21.594144');
INSERT INTO `expenses` VALUES(4,1,2,'2026-07-08','feed','one_time',NULL,1.625356370927738317e+04,'Weekly feed supply','2026-09-29 07:50:21.646968','2026-09-29 07:50:21.646977');
INSERT INTO `expenses` VALUES(5,1,2,'2026-07-15','feed','one_time',NULL,1.655210016411847392e+04,'Weekly feed supply','2026-09-29 07:50:21.686418','2026-09-29 07:50:21.686433');
INSERT INTO `expenses` VALUES(6,1,2,'2026-07-16','labor','one_time',NULL,1.045823865807329457e+04,'Farm hand wages','2026-09-29 07:50:21.686443','2026-09-29 07:50:21.686450');
INSERT INTO `expenses` VALUES(7,1,2,'2026-07-22','feed','one_time',NULL,1.503924695414413326e+04,'Weekly feed supply','2026-09-29 07:50:21.686458','2026-09-29 07:50:21.686467');
INSERT INTO `expenses` VALUES(8,1,2,'2026-07-29','feed','one_time',NULL,1.887515323352471751e+04,'Weekly feed supply','2026-09-29 07:50:21.686475','2026-09-29 07:50:21.686482');
INSERT INTO `expenses` VALUES(9,1,2,'2026-07-31','labor','one_time',NULL,1.154994236387711681e+04,'Farm hand wages','2026-09-29 07:50:21.686490','2026-09-29 07:50:21.686498');
INSERT INTO `expenses` VALUES(10,1,2,'2026-08-01','utilities','one_time',NULL,5.365251259029293579e+03,'Electricity and water bill','2026-09-29 07:50:21.686508','2026-09-29 07:50:21.686516');
INSERT INTO `expenses` VALUES(11,1,2,'2026-08-05','feed','one_time',NULL,1.563359175749628594e+04,'Weekly feed supply','2026-09-29 07:50:21.686525','2026-09-29 07:50:21.686532');
INSERT INTO `expenses` VALUES(12,1,2,'2026-08-12','feed','one_time',NULL,1.777274895215773359e+04,'Weekly feed supply','2026-09-29 07:50:21.686540','2026-09-29 07:50:21.686548');
INSERT INTO `expenses` VALUES(13,1,2,'2026-08-15','labor','one_time',NULL,1.167434222161378602e+04,'Farm hand wages','2026-09-29 07:50:21.686556','2026-09-29 07:50:21.686562');
INSERT INTO `expenses` VALUES(14,1,2,'2026-08-19','feed','one_time',NULL,1.888306229911660921e+04,'Weekly feed supply','2026-09-29 07:50:21.686571','2026-09-29 07:50:21.686578');
INSERT INTO `expenses` VALUES(15,1,2,'2026-08-26','feed','one_time',NULL,1.740834640977140588e+04,'Weekly feed supply','2026-09-29 07:50:21.686586','2026-09-29 07:50:21.686593');
INSERT INTO `expenses` VALUES(16,1,2,'2026-08-30','labor','one_time',NULL,1.07015665378176509e+04,'Farm hand wages','2026-09-29 07:50:21.686602','2026-09-29 07:50:21.686609');
INSERT INTO `expenses` VALUES(17,1,2,'2026-09-01','utilities','one_time',NULL,5099.01600500672,'Electricity and water bill','2026-09-29 07:50:21.686618','2026-09-29 07:50:21.686626');
INSERT INTO `expenses` VALUES(18,1,2,'2026-09-02','feed','one_time',NULL,1.616861384537802769e+04,'Weekly feed supply','2026-09-29 07:50:21.686635','2026-09-29 07:50:21.686643');
INSERT INTO `expenses` VALUES(19,1,2,'2026-09-09','feed','one_time',NULL,1.657066869131820567e+04,'Weekly feed supply','2026-09-29 07:50:21.686708','2026-09-29 07:50:21.686730');
INSERT INTO `expenses` VALUES(20,1,2,'2026-09-14','labor','one_time',NULL,1.053567182894746475e+04,'Farm hand wages','2026-09-29 07:50:21.686744','2026-09-29 07:50:21.686752');
INSERT INTO `expenses` VALUES(21,1,2,'2026-09-16','feed','one_time',NULL,1.666756389238407065e+04,'Weekly feed supply','2026-09-29 07:50:21.686761','2026-09-29 07:50:21.686769');
INSERT INTO `expenses` VALUES(22,1,2,'2026-09-23','feed','one_time',NULL,1.851455596734063511e+04,'Weekly feed supply','2026-09-29 07:50:21.686778','2026-09-29 07:50:21.686786');
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
INSERT INTO `farmer_verifications` VALUES(1,1,'approved',NULL,4,'2026-08-21 15:35:01.881085',NULL,'2026-08-21 15:35:01.882925','2026-08-21 15:35:01.882932');
INSERT INTO `farmer_verifications` VALUES(2,2,'approved',NULL,1,'2026-09-30 05:08:02.395597',NULL,'2026-09-30 05:08:02.398555','2026-09-30 05:08:02.398565');
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
INSERT INTO `farms` VALUES(1,2,'Sunshine Poultry Farm','San Jose, Batangas','Family-owned layer farm specializing in fresh eggs.',4817,1,'2026-09-29 07:50:21.509133','2026-09-29 07:50:21.683897');
CREATE TABLE `feed_records` (
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
INSERT INTO `flock_history` VALUES(1,1,2,'2026-07-01','initial',5000,'Initial batch of layer hens.','2026-09-29 07:50:21.536747');
INSERT INTO `flock_history` VALUES(2,1,2,'2026-07-01','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.621393');
INSERT INTO `flock_history` VALUES(3,1,2,'2026-07-01','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.632591');
INSERT INTO `flock_history` VALUES(4,1,2,'2026-07-02','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.632604');
INSERT INTO `flock_history` VALUES(5,1,2,'2026-07-03','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.637642');
INSERT INTO `flock_history` VALUES(6,1,2,'2026-07-04','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.640683');
INSERT INTO `flock_history` VALUES(7,1,2,'2026-07-04','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.640688');
INSERT INTO `flock_history` VALUES(8,1,2,'2026-07-05','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.640692');
INSERT INTO `flock_history` VALUES(9,1,2,'2026-07-05','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.647535');
INSERT INTO `flock_history` VALUES(10,1,2,'2026-07-08','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694480');
INSERT INTO `flock_history` VALUES(11,1,2,'2026-07-08','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694491');
INSERT INTO `flock_history` VALUES(12,1,2,'2026-07-11','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694496');
INSERT INTO `flock_history` VALUES(13,1,2,'2026-07-12','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694500');
INSERT INTO `flock_history` VALUES(14,1,2,'2026-07-12','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694505');
INSERT INTO `flock_history` VALUES(15,1,2,'2026-07-13','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694509');
INSERT INTO `flock_history` VALUES(16,1,2,'2026-07-14','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694513');
INSERT INTO `flock_history` VALUES(17,1,2,'2026-07-14','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694518');
INSERT INTO `flock_history` VALUES(18,1,2,'2026-07-15','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694522');
INSERT INTO `flock_history` VALUES(19,1,2,'2026-07-15','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694527');
INSERT INTO `flock_history` VALUES(20,1,2,'2026-07-16','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694531');
INSERT INTO `flock_history` VALUES(21,1,2,'2026-07-16','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694535');
INSERT INTO `flock_history` VALUES(22,1,2,'2026-07-17','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694540');
INSERT INTO `flock_history` VALUES(23,1,2,'2026-07-17','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694544');
INSERT INTO `flock_history` VALUES(24,1,2,'2026-07-18','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694549');
INSERT INTO `flock_history` VALUES(25,1,2,'2026-07-18','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694553');
INSERT INTO `flock_history` VALUES(26,1,2,'2026-07-19','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694557');
INSERT INTO `flock_history` VALUES(27,1,2,'2026-07-19','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694562');
INSERT INTO `flock_history` VALUES(28,1,2,'2026-07-20','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694566');
INSERT INTO `flock_history` VALUES(29,1,2,'2026-07-20','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694570');
INSERT INTO `flock_history` VALUES(30,1,2,'2026-07-21','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694575');
INSERT INTO `flock_history` VALUES(31,1,2,'2026-07-22','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694579');
INSERT INTO `flock_history` VALUES(32,1,2,'2026-07-24','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694583');
INSERT INTO `flock_history` VALUES(33,1,2,'2026-07-25','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694588');
INSERT INTO `flock_history` VALUES(34,1,2,'2026-07-25','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694592');
INSERT INTO `flock_history` VALUES(35,1,2,'2026-07-26','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694596');
INSERT INTO `flock_history` VALUES(36,1,2,'2026-07-26','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694601');
INSERT INTO `flock_history` VALUES(37,1,2,'2026-07-27','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694605');
INSERT INTO `flock_history` VALUES(38,1,2,'2026-07-28','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694610');
INSERT INTO `flock_history` VALUES(39,1,2,'2026-07-28','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694614');
INSERT INTO `flock_history` VALUES(40,1,2,'2026-07-30','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694618');
INSERT INTO `flock_history` VALUES(41,1,2,'2026-07-30','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694623');
INSERT INTO `flock_history` VALUES(42,1,2,'2026-08-01','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694627');
INSERT INTO `flock_history` VALUES(43,1,2,'2026-08-02','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694631');
INSERT INTO `flock_history` VALUES(44,1,2,'2026-08-03','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694636');
INSERT INTO `flock_history` VALUES(45,1,2,'2026-08-03','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694640');
INSERT INTO `flock_history` VALUES(46,1,2,'2026-08-04','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694645');
INSERT INTO `flock_history` VALUES(47,1,2,'2026-08-05','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694649');
INSERT INTO `flock_history` VALUES(48,1,2,'2026-08-06','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694653');
INSERT INTO `flock_history` VALUES(49,1,2,'2026-08-07','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694658');
INSERT INTO `flock_history` VALUES(50,1,2,'2026-08-07','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694662');
INSERT INTO `flock_history` VALUES(51,1,2,'2026-08-09','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694670');
INSERT INTO `flock_history` VALUES(52,1,2,'2026-08-10','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694678');
INSERT INTO `flock_history` VALUES(53,1,2,'2026-08-10','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694685');
INSERT INTO `flock_history` VALUES(54,1,2,'2026-08-11','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694693');
INSERT INTO `flock_history` VALUES(55,1,2,'2026-08-11','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694702');
INSERT INTO `flock_history` VALUES(56,1,2,'2026-08-12','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694709');
INSERT INTO `flock_history` VALUES(57,1,2,'2026-08-12','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694716');
INSERT INTO `flock_history` VALUES(58,1,2,'2026-08-13','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694720');
INSERT INTO `flock_history` VALUES(59,1,2,'2026-08-14','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694725');
INSERT INTO `flock_history` VALUES(60,1,2,'2026-08-14','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694729');
INSERT INTO `flock_history` VALUES(61,1,2,'2026-08-15','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694734');
INSERT INTO `flock_history` VALUES(62,1,2,'2026-08-15','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694738');
INSERT INTO `flock_history` VALUES(63,1,2,'2026-08-16','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694743');
INSERT INTO `flock_history` VALUES(64,1,2,'2026-08-16','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694747');
INSERT INTO `flock_history` VALUES(65,1,2,'2026-08-17','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694751');
INSERT INTO `flock_history` VALUES(66,1,2,'2026-08-17','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694755');
INSERT INTO `flock_history` VALUES(67,1,2,'2026-08-18','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694760');
INSERT INTO `flock_history` VALUES(68,1,2,'2026-08-18','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694764');
INSERT INTO `flock_history` VALUES(69,1,2,'2026-08-19','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694769');
INSERT INTO `flock_history` VALUES(70,1,2,'2026-08-20','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694774');
INSERT INTO `flock_history` VALUES(71,1,2,'2026-08-21','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694778');
INSERT INTO `flock_history` VALUES(72,1,2,'2026-08-22','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694782');
INSERT INTO `flock_history` VALUES(73,1,2,'2026-08-22','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694793');
INSERT INTO `flock_history` VALUES(74,1,2,'2026-08-23','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694798');
INSERT INTO `flock_history` VALUES(75,1,2,'2026-08-25','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694802');
INSERT INTO `flock_history` VALUES(76,1,2,'2026-08-25','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694807');
INSERT INTO `flock_history` VALUES(77,1,2,'2026-08-26','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694811');
INSERT INTO `flock_history` VALUES(78,1,2,'2026-08-27','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694815');
INSERT INTO `flock_history` VALUES(79,1,2,'2026-08-28','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694820');
INSERT INTO `flock_history` VALUES(80,1,2,'2026-08-28','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694824');
INSERT INTO `flock_history` VALUES(81,1,2,'2026-08-29','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694829');
INSERT INTO `flock_history` VALUES(82,1,2,'2026-08-29','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694833');
INSERT INTO `flock_history` VALUES(83,1,2,'2026-08-30','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694837');
INSERT INTO `flock_history` VALUES(84,1,2,'2026-08-30','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694842');
INSERT INTO `flock_history` VALUES(85,1,2,'2026-08-31','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694846');
INSERT INTO `flock_history` VALUES(86,1,2,'2026-09-01','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694850');
INSERT INTO `flock_history` VALUES(87,1,2,'2026-09-03','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694855');
INSERT INTO `flock_history` VALUES(88,1,2,'2026-09-03','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694859');
INSERT INTO `flock_history` VALUES(89,1,2,'2026-09-04','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694863');
INSERT INTO `flock_history` VALUES(90,1,2,'2026-09-06','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694868');
INSERT INTO `flock_history` VALUES(91,1,2,'2026-09-07','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694872');
INSERT INTO `flock_history` VALUES(92,1,2,'2026-09-08','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694876');
INSERT INTO `flock_history` VALUES(93,1,2,'2026-09-08','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694881');
INSERT INTO `flock_history` VALUES(94,1,2,'2026-09-09','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694885');
INSERT INTO `flock_history` VALUES(95,1,2,'2026-09-10','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694891');
INSERT INTO `flock_history` VALUES(96,1,2,'2026-09-11','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694898');
INSERT INTO `flock_history` VALUES(97,1,2,'2026-09-12','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694906');
INSERT INTO `flock_history` VALUES(98,1,2,'2026-09-13','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694914');
INSERT INTO `flock_history` VALUES(99,1,2,'2026-09-13','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694921');
INSERT INTO `flock_history` VALUES(100,1,2,'2026-09-14','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694928');
INSERT INTO `flock_history` VALUES(101,1,2,'2026-09-14','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694935');
INSERT INTO `flock_history` VALUES(102,1,2,'2026-09-15','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694942');
INSERT INTO `flock_history` VALUES(103,1,2,'2026-09-16','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694950');
INSERT INTO `flock_history` VALUES(104,1,2,'2026-09-17','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694958');
INSERT INTO `flock_history` VALUES(105,1,2,'2026-09-18','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694966');
INSERT INTO `flock_history` VALUES(106,1,2,'2026-09-18','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.694974');
INSERT INTO `flock_history` VALUES(107,1,2,'2026-09-19','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694982');
INSERT INTO `flock_history` VALUES(108,1,2,'2026-09-20','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694987');
INSERT INTO `flock_history` VALUES(109,1,2,'2026-09-21','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694992');
INSERT INTO `flock_history` VALUES(110,1,2,'2026-09-22','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.694997');
INSERT INTO `flock_history` VALUES(111,1,2,'2026-09-23','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.695001');
INSERT INTO `flock_history` VALUES(112,1,2,'2026-09-23','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.695005');
INSERT INTO `flock_history` VALUES(113,1,2,'2026-09-24','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.695010');
INSERT INTO `flock_history` VALUES(114,1,2,'2026-09-25','mortality',-2,'Daily mortality.','2026-09-29 07:50:21.695014');
INSERT INTO `flock_history` VALUES(115,1,2,'2026-09-25','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.695018');
INSERT INTO `flock_history` VALUES(116,1,2,'2026-09-26','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.695023');
INSERT INTO `flock_history` VALUES(117,1,2,'2026-09-27','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.695027');
INSERT INTO `flock_history` VALUES(118,1,2,'2026-09-28','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.695031');
INSERT INTO `flock_history` VALUES(119,1,2,'2026-09-28','mortality',-1,'Daily mortality.','2026-09-29 07:50:21.695036');
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
CREATE TABLE `mortality_records` (
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
INSERT INTO `mortality_records` VALUES(1,2,3,'2026-08-18',5,'Heat stress',NULL,'2026-08-18 12:58:52.095133','2026-08-18 12:58:52.095144');
INSERT INTO `mortality_records` VALUES(2,5,1,'2026-08-18',1,'1',NULL,'2026-08-18 15:34:37.035946','2026-08-18 15:34:37.035953');
INSERT INTO `mortality_records` VALUES(3,4,1,'2026-08-18',1,'21',NULL,'2026-08-18 15:34:50.906191','2026-08-18 15:34:50.906200');
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
INSERT INTO `order_items` VALUES(1,1,1,20,170);
INSERT INTO `order_items` VALUES(2,2,2,25,190);
INSERT INTO `order_items` VALUES(3,3,4,36,165);
INSERT INTO `order_items` VALUES(4,4,6,10,205);
INSERT INTO `order_items` VALUES(5,5,1,42,170);
INSERT INTO `order_items` VALUES(6,6,4,36,165);
INSERT INTO `order_items` VALUES(7,7,6,35,205);
INSERT INTO `order_items` VALUES(8,8,1,13,170);
INSERT INTO `order_items` VALUES(9,9,5,43,185);
INSERT INTO `order_items` VALUES(10,10,1,20,170);
INSERT INTO `order_items` VALUES(11,11,2,27,190);
INSERT INTO `order_items` VALUES(12,12,2,26,190);
INSERT INTO `order_items` VALUES(13,13,4,5,165);
INSERT INTO `order_items` VALUES(14,14,1,5,170);
INSERT INTO `order_items` VALUES(15,15,6,15,205);
INSERT INTO `order_items` VALUES(16,16,5,33,185);
INSERT INTO `order_items` VALUES(17,17,3,14,210);
INSERT INTO `order_items` VALUES(18,18,5,26,185);
INSERT INTO `order_items` VALUES(19,19,4,40,165);
INSERT INTO `order_items` VALUES(20,20,1,28,170);
INSERT INTO `order_items` VALUES(21,21,5,21,185);
INSERT INTO `order_items` VALUES(22,22,4,27,165);
INSERT INTO `order_items` VALUES(23,23,1,11,170);
INSERT INTO `order_items` VALUES(24,24,6,42,205);
INSERT INTO `order_items` VALUES(25,25,3,8,210);
INSERT INTO `order_items` VALUES(26,26,5,24,185);
INSERT INTO `order_items` VALUES(27,27,2,44,190);
INSERT INTO `order_items` VALUES(28,28,5,24,185);
INSERT INTO `order_items` VALUES(29,29,3,27,210);
INSERT INTO `order_items` VALUES(30,30,1,22,170);
INSERT INTO `order_items` VALUES(31,31,2,15,190);
INSERT INTO `order_items` VALUES(32,32,4,49,165);
INSERT INTO `order_items` VALUES(33,33,4,15,165);
INSERT INTO `order_items` VALUES(34,34,5,29,185);
INSERT INTO `order_items` VALUES(35,35,2,19,190);
INSERT INTO `order_items` VALUES(36,36,1,49,170);
INSERT INTO `order_items` VALUES(37,37,2,17,190);
INSERT INTO `order_items` VALUES(38,38,6,30,205);
INSERT INTO `order_items` VALUES(39,39,1,33,170);
INSERT INTO `order_items` VALUES(40,40,3,11,210);
INSERT INTO `order_items` VALUES(41,41,1,17,170);
INSERT INTO `order_items` VALUES(42,42,6,20,205);
INSERT INTO `order_items` VALUES(43,43,1,47,170);
INSERT INTO `order_items` VALUES(44,44,6,25,205);
INSERT INTO `order_items` VALUES(45,45,1,5,170);
INSERT INTO `order_items` VALUES(46,46,5,34,185);
INSERT INTO `order_items` VALUES(47,47,4,39,165);
INSERT INTO `order_items` VALUES(48,48,6,23,205);
INSERT INTO `order_items` VALUES(49,49,1,16,170);
INSERT INTO `order_items` VALUES(50,50,2,25,190);
INSERT INTO `order_items` VALUES(51,51,2,10,190);
INSERT INTO `order_items` VALUES(52,52,6,42,205);
INSERT INTO `order_items` VALUES(53,53,3,10,210);
INSERT INTO `order_items` VALUES(54,54,3,46,210);
INSERT INTO `order_items` VALUES(55,55,5,21,185);
INSERT INTO `order_items` VALUES(56,56,2,44,190);
INSERT INTO `order_items` VALUES(57,57,6,45,205);
INSERT INTO `order_items` VALUES(58,58,3,15,210);
INSERT INTO `order_items` VALUES(59,59,3,19,210);
INSERT INTO `order_items` VALUES(60,60,2,24,190);
INSERT INTO `order_items` VALUES(61,61,2,39,190);
INSERT INTO `order_items` VALUES(62,62,4,8,165);
INSERT INTO `order_items` VALUES(63,63,1,11,170);
INSERT INTO `order_items` VALUES(64,64,5,35,185);
INSERT INTO `order_items` VALUES(65,65,2,27,190);
INSERT INTO `order_items` VALUES(66,66,5,24,185);
INSERT INTO `order_items` VALUES(67,67,6,24,205);
INSERT INTO `order_items` VALUES(68,68,1,21,170);
INSERT INTO `order_items` VALUES(69,69,4,33,165);
INSERT INTO `order_items` VALUES(70,70,6,31,205);
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
INSERT INTO `orders` VALUES(1,3,3400,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-12 15:00:00.000000','2026-07-12 15:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(2,3,4750,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-08 13:00:00.000000','2026-07-08 13:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(3,3,5940,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-09 09:00:00.000000','2026-08-09 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(4,3,2050,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-08 09:00:00.000000','2026-08-08 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(5,3,7140,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-18 17:00:00.000000','2026-07-18 17:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(6,3,5940,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-18 08:00:00.000000','2026-07-18 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(7,3,7175,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-05 16:00:00.000000','2026-07-05 16:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(8,3,2210,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-04 10:00:00.000000','2026-07-04 10:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(9,3,7955,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-01 12:00:00.000000','2026-08-01 12:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(10,3,3400,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-23 18:00:00.000000','2026-07-23 18:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(11,3,5130,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-13 09:00:00.000000','2026-08-13 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(12,3,4940,'completed','123 Buyer St, Manila','09189876543',NULL,'2026-09-22 17:00:00.000000','2026-09-30 06:14:14.678242','COD',NULL,1,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(13,3,825,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-31 13:00:00.000000','2026-07-31 13:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(14,3,850,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-20 15:00:00.000000','2026-07-20 15:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(15,3,3075,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-02 09:00:00.000000','2026-07-02 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(16,3,6105,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-25 14:00:00.000000','2026-07-25 14:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(17,3,2940,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-16 08:00:00.000000','2026-09-16 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(18,3,4810,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-16 17:00:00.000000','2026-07-16 17:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(19,3,6600,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-17 17:00:00.000000','2026-09-17 17:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(20,3,4760,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-13 11:00:00.000000','2026-09-13 11:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(21,3,3885,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-31 09:00:00.000000','2026-07-31 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(22,3,4455,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-12 08:00:00.000000','2026-07-12 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(23,3,1870,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-10 13:00:00.000000','2026-07-10 13:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(24,3,8610,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-06 11:00:00.000000','2026-09-06 11:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(25,3,1680,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-11 18:00:00.000000','2026-07-11 18:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(26,3,4440,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-09 15:00:00.000000','2026-09-09 15:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(27,3,8360,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-22 10:00:00.000000','2026-07-22 10:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(28,3,4440,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-15 15:00:00.000000','2026-08-15 15:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(29,3,5670,'pending','123 Buyer St, Manila','09189876543',NULL,'2026-09-29 12:00:00.000000','2026-09-29 12:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(30,3,3740,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-01 16:00:00.000000','2026-07-01 16:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(31,3,2850,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-07 14:00:00.000000','2026-09-07 14:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(32,3,8085,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-10 17:00:00.000000','2026-08-10 17:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(33,3,2475,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-18 15:00:00.000000','2026-09-18 15:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(34,3,5365,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-05 13:00:00.000000','2026-07-05 13:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(35,3,3610,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-05 15:00:00.000000','2026-09-05 15:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(36,3,8330,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-16 08:00:00.000000','2026-09-16 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(37,3,3230,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-17 16:00:00.000000','2026-07-17 16:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(38,3,6150,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-13 16:00:00.000000','2026-08-13 16:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(39,3,5610,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-07 18:00:00.000000','2026-07-07 18:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(40,3,2310,'completed','123 Buyer St, Manila','09189876543',NULL,'2026-09-22 11:00:00.000000','2026-09-30 06:17:23.961838','COD',NULL,1,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(41,3,2890,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-09 11:00:00.000000','2026-09-09 11:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(42,3,4100,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-13 11:00:00.000000','2026-08-13 11:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(43,3,7990,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-12 14:00:00.000000','2026-08-12 14:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(44,3,5125,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-05 12:00:00.000000','2026-09-05 12:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(45,3,850,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-11 15:00:00.000000','2026-07-11 15:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(46,3,6290,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-06 08:00:00.000000','2026-07-06 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(47,3,6435,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-25 12:00:00.000000','2026-08-25 12:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(48,3,4715,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-07 17:00:00.000000','2026-07-07 17:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(49,3,2720,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-17 18:00:00.000000','2026-09-17 18:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(50,3,4750,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-21 16:00:00.000000','2026-09-21 16:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(51,3,1900,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-07 13:00:00.000000','2026-08-07 13:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(52,3,8610,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-15 18:00:00.000000','2026-08-15 18:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(53,3,2100,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-05 13:00:00.000000','2026-07-05 13:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(54,3,9660,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-27 13:00:00.000000','2026-08-27 13:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(55,3,3885,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-28 08:00:00.000000','2026-08-28 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(56,3,8360,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-31 17:00:00.000000','2026-07-31 17:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(57,3,9225,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-06 18:00:00.000000','2026-08-06 18:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(58,3,3150,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-25 11:00:00.000000','2026-07-25 11:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(59,3,3990,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-24 09:00:00.000000','2026-07-24 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(60,3,4560,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-03 15:00:00.000000','2026-08-03 15:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(61,3,7410,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-13 08:00:00.000000','2026-09-13 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(62,3,1320,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-17 08:00:00.000000','2026-07-17 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(63,3,1870,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-14 11:00:00.000000','2026-09-14 11:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(64,3,6475,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-17 09:00:00.000000','2026-08-17 09:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(65,3,5130,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-30 17:00:00.000000','2026-07-30 17:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(66,3,4440,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-09 10:00:00.000000','2026-08-09 10:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(67,3,4920,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-08-31 16:00:00.000000','2026-08-31 16:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(68,3,3570,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-23 08:00:00.000000','2026-07-23 08:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(69,3,5445,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-07-03 15:00:00.000000','2026-07-03 15:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO `orders` VALUES(70,3,6355,'delivered','123 Buyer St, Manila','09189876543',NULL,'2026-09-18 17:00:00.000000','2026-09-18 17:00:00.000000','COD',NULL,NULL,NULL,NULL,NULL,NULL,NULL);
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
INSERT INTO `production_records` VALUES(1,1,2,'2026-07-01',1863,'large','brown',2.976737015264213824e+02,1.10208497838538392e+03,7,2,NULL,'2026-09-29 07:50:21.625350','2026-09-29 07:50:21.625370');
INSERT INTO `production_records` VALUES(2,1,2,'2026-07-01',1697,'medium','white',2.53630493299841163e+02,1.055981308381809641e+03,6.166666666666666963e+00,1,NULL,'2026-09-29 07:50:21.634484','2026-09-29 07:50:21.634491');
INSERT INTO `production_records` VALUES(3,1,2,'2026-07-02',2137,'large','brown',2.968588004826814313e+02,1.03634966497639789e+03,7,1,NULL,'2026-09-29 07:50:21.634495','2026-09-29 07:50:21.634499');
INSERT INTO `production_records` VALUES(4,1,2,'2026-07-02',1806,'medium','white',274.611567971882,1.040819444562368516e+03,6.166666666666666963e+00,0,NULL,'2026-09-29 07:50:21.634502','2026-09-29 07:50:21.634506');
INSERT INTO `production_records` VALUES(5,1,2,'2026-07-03',1658,'medium','brown',2.750703427099839474e+02,1.020222914433202959e+03,6.333333333333333037e+00,1,NULL,'2026-09-29 07:50:21.637993','2026-09-29 07:50:21.637998');
INSERT INTO `production_records` VALUES(6,1,2,'2026-07-03',2010,'large','brown',2.657090285740602553e+02,1.23665400407303332e+03,7,0,NULL,'2026-09-29 07:50:21.638002','2026-09-29 07:50:21.638005');
INSERT INTO `production_records` VALUES(7,1,2,'2026-07-04',1896,'small','white',2.935472417780252954e+02,1.089015872052514623e+03,5.5,2,NULL,'2026-09-29 07:50:21.641423','2026-09-29 07:50:21.641431');
INSERT INTO `production_records` VALUES(8,1,2,'2026-07-04',1712,'medium','brown',2.537246961446502098e+02,1.002536075767634657e+03,6.333333333333333037e+00,2,NULL,'2026-09-29 07:50:21.641438','2026-09-29 07:50:21.641443');
INSERT INTO `production_records` VALUES(9,1,2,'2026-07-05',1619,'medium','brown',2.505836239039210796e+02,1.163010103485884884e+03,6.333333333333333037e+00,1,NULL,'2026-09-29 07:50:21.641448','2026-09-29 07:50:21.641453');
INSERT INTO `production_records` VALUES(10,1,2,'2026-07-05',2119,'small','brown',2.977278766367713842e+02,1.142538420045331578e+03,5.666666666666666963e+00,2,NULL,'2026-09-29 07:50:21.648205','2026-09-29 07:50:21.648214');
INSERT INTO `production_records` VALUES(11,1,2,'2026-07-06',2073,'small','brown',2.91831430222138863e+02,1.162968118785484422e+03,5.666666666666666963e+00,0,NULL,'2026-09-29 07:50:21.648220','2026-09-29 07:50:21.648226');
INSERT INTO `production_records` VALUES(12,1,2,'2026-07-06',2137,'small','white',2.646075043115431526e+02,1.108981079775127682e+03,5.5,0,NULL,'2026-09-29 07:50:21.648232','2026-09-29 07:50:21.648238');
INSERT INTO `production_records` VALUES(13,1,2,'2026-07-07',1729,'medium','brown',2.766114116735587344e+02,1.236947145074182572e+03,6.333333333333333037e+00,0,NULL,'2026-09-29 07:50:21.648244','2026-09-29 07:50:21.648249');
INSERT INTO `production_records` VALUES(14,1,2,'2026-07-07',1806,'small','white',2.706617581312163451e+02,1.089653508523354503e+03,5.5,0,NULL,'2026-09-29 07:50:21.648255','2026-09-29 07:50:21.648261');
INSERT INTO `production_records` VALUES(15,1,2,'2026-07-08',2475,'large','white',2.753922859313536833e+02,1.067637497412069251e+03,6.833333333333333037e+00,1,NULL,'2026-09-29 07:50:21.707305','2026-09-29 07:50:21.707315');
INSERT INTO `production_records` VALUES(16,1,2,'2026-07-08',2035,'medium','white',2.988935879054213842e+02,1.059132805242684298e+03,6.166666666666666963e+00,2,NULL,'2026-09-29 07:50:21.707321','2026-09-29 07:50:21.707325');
INSERT INTO `production_records` VALUES(17,1,2,'2026-07-09',1641,'small','white',2.697331337328495237e+02,1.173456851880576778e+03,5.5,0,NULL,'2026-09-29 07:50:21.707330','2026-09-29 07:50:21.707334');
INSERT INTO `production_records` VALUES(18,1,2,'2026-07-09',2253,'large','brown',2.844695063200246068e+02,1.08232033125637713e+03,7,0,NULL,'2026-09-29 07:50:21.707339','2026-09-29 07:50:21.707343');
INSERT INTO `production_records` VALUES(19,1,2,'2026-07-10',1624,'large','brown',2.705061520478949432e+02,1.235998538733992972e+03,7,0,NULL,'2026-09-29 07:50:21.707347','2026-09-29 07:50:21.707352');
INSERT INTO `production_records` VALUES(20,1,2,'2026-07-10',1916,'large','white',2.580225181393915364e+02,1.098451788683776157e+03,6.833333333333333037e+00,0,NULL,'2026-09-29 07:50:21.707356','2026-09-29 07:50:21.707361');
INSERT INTO `production_records` VALUES(21,1,2,'2026-07-11',1809,'large','white',2.908475927711940586e+02,1.024943086517847406e+03,6.833333333333333037e+00,0,NULL,'2026-09-29 07:50:21.707365','2026-09-29 07:50:21.707369');
INSERT INTO `production_records` VALUES(22,1,2,'2026-07-11',1770,'medium','white',2.777830489254765211e+02,1.063151584513418811e+03,6.166666666666666963e+00,2,NULL,'2026-09-29 07:50:21.707373','2026-09-29 07:50:21.707378');
INSERT INTO `production_records` VALUES(23,1,2,'2026-07-12',1877,'large','white',2.615831595713428329e+02,1.148054797980354351e+03,6.833333333333333037e+00,2,NULL,'2026-09-29 07:50:21.707382','2026-09-29 07:50:21.707386');
INSERT INTO `production_records` VALUES(24,1,2,'2026-07-12',2155,'large','brown',2.770796505379248061e+02,1.19702104807219962e+03,7,2,NULL,'2026-09-29 07:50:21.707391','2026-09-29 07:50:21.707395');
INSERT INTO `production_records` VALUES(25,1,2,'2026-07-13',2362,'large','white',2.731664719490577227e+02,1092.88729466587,6.833333333333333037e+00,0,NULL,'2026-09-29 07:50:21.707399','2026-09-29 07:50:21.707403');
INSERT INTO `production_records` VALUES(26,1,2,'2026-07-13',1575,'medium','brown',2.976315692278201368e+02,1.088589993343345896e+03,6.333333333333333037e+00,1,NULL,'2026-09-29 07:50:21.707408','2026-09-29 07:50:21.707412');
INSERT INTO `production_records` VALUES(27,1,2,'2026-07-14',1911,'large','brown',2.62393442308453416e+02,1113.16263891552,7,1,NULL,'2026-09-29 07:50:21.707416','2026-09-29 07:50:21.707421');
INSERT INTO `production_records` VALUES(28,1,2,'2026-07-14',2201,'small','white',2.615497676468891654e+02,1.218555996744224103e+03,5.5,1,NULL,'2026-09-29 07:50:21.707425','2026-09-29 07:50:21.707429');
INSERT INTO `production_records` VALUES(29,1,2,'2026-07-15',2124,'small','white',2.876709118857104954e+02,1.210502110034414728e+03,5.5,1,NULL,'2026-09-29 07:50:21.707434','2026-09-29 07:50:21.707438');
INSERT INTO `production_records` VALUES(30,1,2,'2026-07-15',1932,'large','white',2.946543830208377131e+02,1.046941650470424293e+03,6.833333333333333037e+00,2,NULL,'2026-09-29 07:50:21.707442','2026-09-29 07:50:21.707446');
INSERT INTO `production_records` VALUES(31,1,2,'2026-07-16',1784,'large','white',2.517041016371191802e+02,1.06944315648067709e+03,6.833333333333333037e+00,1,NULL,'2026-09-29 07:50:21.707451','2026-09-29 07:50:21.707455');
INSERT INTO `production_records` VALUES(32,1,2,'2026-07-16',2306,'small','white',2.754526918906508967e+02,1.055007502013113709e+03,5.5,1,NULL,'2026-09-29 07:50:21.707459','2026-09-29 07:50:21.707463');
INSERT INTO `production_records` VALUES(33,1,2,'2026-07-17',1719,'small','white',2.735320489120536536e+02,1.046112589055108628e+03,5.5,1,NULL,'2026-09-29 07:50:21.707468','2026-09-29 07:50:21.707472');
INSERT INTO `production_records` VALUES(34,1,2,'2026-07-17',2010,'medium','brown',2.502658394900449253e+02,1.129730402339609555e+03,6.333333333333333037e+00,1,NULL,'2026-09-29 07:50:21.707478','2026-09-29 07:50:21.707483');
INSERT INTO `production_records` VALUES(35,1,2,'2026-07-18',1513,'medium','brown',2.934410204053245366e+02,1.140273390699651372e+03,6.333333333333333037e+00,2,NULL,'2026-09-29 07:50:21.707487','2026-09-29 07:50:21.707491');
INSERT INTO `production_records` VALUES(36,1,2,'2026-07-18',2007,'large','brown',2.862884302456433829e+02,1.106070302400994252e+03,7,2,NULL,'2026-09-29 07:50:21.707496','2026-09-29 07:50:21.707500');
INSERT INTO `production_records` VALUES(37,1,2,'2026-07-19',2289,'medium','white',2.610069194797742398e+02,1.17202085831446857e+03,6.166666666666666963e+00,1,NULL,'2026-09-29 07:50:21.707504','2026-09-29 07:50:21.707508');
INSERT INTO `production_records` VALUES(38,1,2,'2026-07-19',2276,'large','white',2.92885958826444778e+02,1.151668622921127281e+03,6.833333333333333037e+00,2,NULL,'2026-09-29 07:50:21.707512','2026-09-29 07:50:21.707517');
INSERT INTO `production_records` VALUES(39,1,2,'2026-07-20',1807,'medium','white',2.6929285035330048e+02,1.18322689085345155e+03,6.166666666666666963e+00,2,NULL,'2026-09-29 07:50:21.707521','2026-09-29 07:50:21.707525');
INSERT INTO `production_records` VALUES(40,1,2,'2026-07-20',1573,'small','white',2.916425310248795312e+02,1.096525030504262304e+03,5.5,2,NULL,'2026-09-29 07:50:21.707532','2026-09-29 07:50:21.707539');
INSERT INTO `production_records` VALUES(41,1,2,'2026-07-21',1618,'medium','white',2.679755366568015802e+02,1.115076461039349625e+03,6.166666666666666963e+00,0,NULL,'2026-09-29 07:50:21.707548','2026-09-29 07:50:21.707555');
INSERT INTO `production_records` VALUES(42,1,2,'2026-07-21',1637,'small','white',2.699743497936584618e+02,1.223353133165182271e+03,5.5,2,NULL,'2026-09-29 07:50:21.707563','2026-09-29 07:50:21.707570');
INSERT INTO `production_records` VALUES(43,1,2,'2026-07-22',1757,'large','brown',2.50706680424302931e+02,1.205923897536363257e+03,7,0,NULL,'2026-09-29 07:50:21.707578','2026-09-29 07:50:21.707585');
INSERT INTO `production_records` VALUES(44,1,2,'2026-07-22',2478,'medium','brown',2.959814779240094821e+02,1.170368610598798569e+03,6.333333333333333037e+00,1,NULL,'2026-09-29 07:50:21.707593','2026-09-29 07:50:21.707602');
INSERT INTO `production_records` VALUES(45,1,2,'2026-07-23',2003,'medium','brown',2.666776201266628163e+02,1.141085619617984548e+03,6.333333333333333037e+00,0,NULL,'2026-09-29 07:50:21.707611','2026-09-29 07:50:21.707618');
INSERT INTO `production_records` VALUES(46,1,2,'2026-07-23',1537,'large','brown',2.817496792887804417e+02,1109.02505788341,7,0,NULL,'2026-09-29 07:50:21.707625','2026-09-29 07:50:21.707633');
INSERT INTO `production_records` VALUES(47,1,2,'2026-07-24',1599,'small','white',2.824423067888528181e+02,1.234169806654868353e+03,5.5,0,NULL,'2026-09-29 07:50:21.707640','2026-09-29 07:50:21.707648');
INSERT INTO `production_records` VALUES(48,1,2,'2026-07-24',2299,'medium','white',2.918856298942966418e+02,1.044047656607462614e+03,6.166666666666666963e+00,1,NULL,'2026-09-29 07:50:21.707655','2026-09-29 07:50:21.707663');
INSERT INTO `production_records` VALUES(49,1,2,'2026-07-25',2054,'small','brown',2.619641564853190517e+02,1.085229692749698643e+03,5.666666666666666963e+00,1,NULL,'2026-09-29 07:50:21.707671','2026-09-29 07:50:21.707678');
INSERT INTO `production_records` VALUES(50,1,2,'2026-07-25',1926,'medium','white',2.9361741772174787e+02,1.167391768459244076e+03,6.166666666666666963e+00,2,NULL,'2026-09-29 07:50:21.707685','2026-09-29 07:50:21.707692');
INSERT INTO `production_records` VALUES(51,1,2,'2026-07-26',1896,'medium','white',2.835408407025720407e+02,1.193849827158067e+03,6.166666666666666963e+00,2,NULL,'2026-09-29 07:50:21.707699','2026-09-29 07:50:21.707706');
INSERT INTO `production_records` VALUES(52,1,2,'2026-07-26',2488,'small','brown',262.066591399278,1.096166859085241413e+03,5.666666666666666963e+00,1,NULL,'2026-09-29 07:50:21.707714','2026-09-29 07:50:21.707721');
INSERT INTO `production_records` VALUES(53,1,2,'2026-07-27',1667,'large','brown',2.716332937727804619e+02,1.212055303169423042e+03,7,1,NULL,'2026-09-29 07:50:21.707729','2026-09-29 07:50:21.707736');
INSERT INTO `production_records` VALUES(54,1,2,'2026-07-27',1975,'medium','white',2.518479867652782218e+02,1.166479913652691266e+03,6.166666666666666963e+00,0,NULL,'2026-09-29 07:50:21.707744','2026-09-29 07:50:21.707751');
INSERT INTO `production_records` VALUES(55,1,2,'2026-07-28',1569,'large','brown',2.965152430877955112e+02,1.110202854934504102e+03,7,2,NULL,'2026-09-29 07:50:21.707758','2026-09-29 07:50:21.707765');
INSERT INTO `production_records` VALUES(56,1,2,'2026-07-28',1736,'small','brown',2.982126339343661243e+02,1.053735026197807655e+03,5.666666666666666963e+00,1,NULL,'2026-09-29 07:50:21.707773','2026-09-29 07:50:21.707780');
INSERT INTO `production_records` VALUES(57,1,2,'2026-07-29',1964,'small','brown',2.535736690190594231e+02,1.182544449616206294e+03,5.666666666666666963e+00,0,NULL,'2026-09-29 07:50:21.707788','2026-09-29 07:50:21.707794');
INSERT INTO `production_records` VALUES(58,1,2,'2026-07-29',2073,'large','white',2.997438446803923285e+02,1.211162415777351952e+03,6.833333333333333037e+00,0,NULL,'2026-09-29 07:50:21.707801','2026-09-29 07:50:21.707808');
INSERT INTO `production_records` VALUES(59,1,2,'2026-07-30',2306,'medium','white',2.781637905954215171e+02,1.030949193292908149e+03,6.166666666666666963e+00,2,NULL,'2026-09-29 07:50:21.707815','2026-09-29 07:50:21.707822');
INSERT INTO `production_records` VALUES(60,1,2,'2026-07-30',2021,'small','white',2.507674757462098114e+02,1.167706270017672069e+03,5.5,1,NULL,'2026-09-29 07:50:21.707830','2026-09-29 07:50:21.707837');
INSERT INTO `production_records` VALUES(61,1,2,'2026-07-31',2370,'small','brown',2.722874288583001885e+02,1.205053072694214506e+03,5.666666666666666963e+00,0,NULL,'2026-09-29 07:50:21.707844','2026-09-29 07:50:21.707851');
INSERT INTO `production_records` VALUES(62,1,2,'2026-07-31',1955,'medium','white',2.806413116720082143e+02,1.095705432832220594e+03,6.166666666666666963e+00,0,NULL,'2026-09-29 07:50:21.707859','2026-09-29 07:50:21.707866');
INSERT INTO `production_records` VALUES(63,1,2,'2026-08-01',1723,'large','brown',2.50326590800008944e+02,1.003738194309217419e+03,7,0,NULL,'2026-09-29 07:50:21.707873','2026-09-29 07:50:21.707880');
INSERT INTO `production_records` VALUES(64,1,2,'2026-08-01',2067,'medium','white',2.714727808966019324e+02,1.182969712422896463e+03,6.166666666666666963e+00,2,NULL,'2026-09-29 07:50:21.707888','2026-09-29 07:50:21.707895');
INSERT INTO `production_records` VALUES(65,1,2,'2026-08-02',2080,'small','white',2.999499763944479583e+02,1.058031964683747447e+03,5.5,0,NULL,'2026-09-29 07:50:21.707902','2026-09-29 07:50:21.707909');
INSERT INTO `production_records` VALUES(66,1,2,'2026-08-02',2336,'large','brown',2.641411208300170301e+02,1.029295625734539727e+03,7,2,NULL,'2026-09-29 07:50:21.707917','2026-09-29 07:50:21.707924');
INSERT INTO `production_records` VALUES(67,1,2,'2026-08-03',2076,'medium','white',2.687835258115834449e+02,1.108249163276752598e+03,6.166666666666666963e+00,1,NULL,'2026-09-29 07:50:21.707931','2026-09-29 07:50:21.707938');
INSERT INTO `production_records` VALUES(68,1,2,'2026-08-03',1627,'medium','brown',2.806998023726596329e+02,1.1456270145581816e+03,6.333333333333333037e+00,1,NULL,'2026-09-29 07:50:21.707945','2026-09-29 07:50:21.707952');
INSERT INTO `production_records` VALUES(69,1,2,'2026-08-04',2085,'large','white',2.700536682768083664e+02,1.145398070422947058e+03,6.833333333333333037e+00,1,NULL,'2026-09-29 07:50:21.707959','2026-09-29 07:50:21.707966');
INSERT INTO `production_records` VALUES(70,1,2,'2026-08-04',1565,'medium','white',294.578794834861,1.2152492638146432e+03,6.166666666666666963e+00,0,NULL,'2026-09-29 07:50:21.707975','2026-09-29 07:50:21.707982');
INSERT INTO `production_records` VALUES(71,1,2,'2026-08-05',1695,'medium','white',2.866290046113840618e+02,1.205026060822410499e+03,6.166666666666666963e+00,2,NULL,'2026-09-29 07:50:21.707990','2026-09-29 07:50:21.707999');
INSERT INTO `production_records` VALUES(72,1,2,'2026-08-05',2378,'large','brown',2.613161962955611557e+02,1.042895695129815067e+03,7,0,NULL,'2026-09-29 07:50:21.708007','2026-09-29 07:50:21.708014');
INSERT INTO `production_records` VALUES(73,1,2,'2026-08-06',2375,'small','brown',2.830830967181789219e+02,1.000467494714601912e+03,5.666666666666666963e+00,0,NULL,'2026-09-29 07:50:21.708022','2026-09-29 07:50:21.708029');
INSERT INTO `production_records` VALUES(74,1,2,'2026-08-06',2290,'small','white',2.699414754768845909e+02,1.165784251340268838e+03,5.5,2,NULL,'2026-09-29 07:50:21.708037','2026-09-29 07:50:21.708044');
INSERT INTO `production_records` VALUES(75,1,2,'2026-08-07',1874,'small','brown',2.594921582245618765e+02,1.087544657888800885e+03,5.666666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708052','2026-09-29 07:50:21.708060');
INSERT INTO `production_records` VALUES(76,1,2,'2026-08-07',1863,'large','white',2.737967430509615952e+02,1.129516525799553846e+03,6.833333333333333037e+00,2,NULL,'2026-09-29 07:50:21.708069','2026-09-29 07:50:21.708077');
INSERT INTO `production_records` VALUES(77,1,2,'2026-08-08',1940,'small','brown',298.351050553369,1151.4172099187,5.666666666666666963e+00,0,NULL,'2026-09-29 07:50:21.708084','2026-09-29 07:50:21.708092');
INSERT INTO `production_records` VALUES(78,1,2,'2026-08-08',2484,'large','brown',2.925859697446495602e+02,1.194058010688265767e+03,7,0,NULL,'2026-09-29 07:50:21.708100','2026-09-29 07:50:21.708107');
INSERT INTO `production_records` VALUES(79,1,2,'2026-08-09',2098,'medium','brown',253.573978167822,1.040462473264519531e+03,6.333333333333333037e+00,1,NULL,'2026-09-29 07:50:21.708115','2026-09-29 07:50:21.708123');
INSERT INTO `production_records` VALUES(80,1,2,'2026-08-09',2411,'small','brown',2.857603008452491622e+02,1.086328965209411762e+03,5.666666666666666963e+00,0,NULL,'2026-09-29 07:50:21.708130','2026-09-29 07:50:21.708138');
INSERT INTO `production_records` VALUES(81,1,2,'2026-08-10',1997,'large','white',2.911811063576232072e+02,1.089364634702937793e+03,6.833333333333333037e+00,1,NULL,'2026-09-29 07:50:21.708146','2026-09-29 07:50:21.708153');
INSERT INTO `production_records` VALUES(82,1,2,'2026-08-10',2295,'large','brown',2.737038947292614352e+02,1.050555364753287677e+03,7,2,NULL,'2026-09-29 07:50:21.708160','2026-09-29 07:50:21.708165');
INSERT INTO `production_records` VALUES(83,1,2,'2026-08-11',1846,'small','brown',2.801329142215865318e+02,1.241785962694082627e+03,5.666666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708169','2026-09-29 07:50:21.708173');
INSERT INTO `production_records` VALUES(84,1,2,'2026-08-11',1520,'large','brown',2.557503590598526842e+02,1.185860114879223374e+03,7,2,NULL,'2026-09-29 07:50:21.708178','2026-09-29 07:50:21.708182');
INSERT INTO `production_records` VALUES(85,1,2,'2026-08-12',1697,'small','brown',2.696650559559301997e+02,1.115756850153621372e+03,5.666666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708187','2026-09-29 07:50:21.708191');
INSERT INTO `production_records` VALUES(86,1,2,'2026-08-12',1757,'small','white',2.710548697269432523e+02,1.135250732968713919e+03,5.5,2,NULL,'2026-09-29 07:50:21.708195','2026-09-29 07:50:21.708200');
INSERT INTO `production_records` VALUES(87,1,2,'2026-08-13',1958,'small','white',260.483722002558,1.053689847261161276e+03,5.5,2,NULL,'2026-09-29 07:50:21.708204','2026-09-29 07:50:21.708208');
INSERT INTO `production_records` VALUES(88,1,2,'2026-08-13',1943,'large','brown',2.635775704205644275e+02,1.242776176913733253e+03,7,0,NULL,'2026-09-29 07:50:21.708212','2026-09-29 07:50:21.708217');
INSERT INTO `production_records` VALUES(89,1,2,'2026-08-14',1528,'small','white',2.892242539138097754e+02,1.02109096628062207e+03,5.5,2,NULL,'2026-09-29 07:50:21.708221','2026-09-29 07:50:21.708225');
INSERT INTO `production_records` VALUES(90,1,2,'2026-08-14',1769,'medium','brown',2.851424034500630568e+02,1.095144559367894544e+03,6.333333333333333037e+00,2,NULL,'2026-09-29 07:50:21.708230','2026-09-29 07:50:21.708234');
INSERT INTO `production_records` VALUES(91,1,2,'2026-08-15',2201,'large','brown',2.788671894892526097e+02,1.181788324747940579e+03,7,1,NULL,'2026-09-29 07:50:21.708239','2026-09-29 07:50:21.708243');
INSERT INTO `production_records` VALUES(92,1,2,'2026-08-15',1567,'large','white',2.808990873576323679e+02,1.182863463088555363e+03,6.833333333333333037e+00,2,NULL,'2026-09-29 07:50:21.708248','2026-09-29 07:50:21.708252');
INSERT INTO `production_records` VALUES(93,1,2,'2026-08-16',2228,'medium','brown',2.796422043930196537e+02,1.188157317149807341e+03,6.333333333333333037e+00,1,NULL,'2026-09-29 07:50:21.708256','2026-09-29 07:50:21.708260');
INSERT INTO `production_records` VALUES(94,1,2,'2026-08-16',1961,'large','brown',2.509917276652037117e+02,1.145360785915292808e+03,7,1,NULL,'2026-09-29 07:50:21.708265','2026-09-29 07:50:21.708269');
INSERT INTO `production_records` VALUES(95,1,2,'2026-08-17',1590,'medium','brown',2.629853104198915616e+02,1.100990515978921849e+03,6.333333333333333037e+00,2,NULL,'2026-09-29 07:50:21.708273','2026-09-29 07:50:21.708278');
INSERT INTO `production_records` VALUES(96,1,2,'2026-08-17',1840,'large','brown',2.594890316388077735e+02,1.201862869976256434e+03,7,2,NULL,'2026-09-29 07:50:21.708282','2026-09-29 07:50:21.708286');
INSERT INTO `production_records` VALUES(97,1,2,'2026-08-18',1946,'large','brown',2.678132339865172753e+02,1.23397151476317481e+03,7,2,NULL,'2026-09-29 07:50:21.708291','2026-09-29 07:50:21.708295');
INSERT INTO `production_records` VALUES(98,1,2,'2026-08-18',1878,'small','brown',2.989941568749680414e+02,1.034385811016491288e+03,5.666666666666666963e+00,1,NULL,'2026-09-29 07:50:21.708299','2026-09-29 07:50:21.708304');
INSERT INTO `production_records` VALUES(99,1,2,'2026-08-19',1618,'large','brown',277.221941442204,1.177985029385292136e+03,7,1,NULL,'2026-09-29 07:50:21.708308','2026-09-29 07:50:21.708312');
INSERT INTO `production_records` VALUES(100,1,2,'2026-08-19',1900,'medium','brown',2.584894470685211446e+02,1.098243109388505673e+03,6.333333333333333037e+00,0,NULL,'2026-09-29 07:50:21.708317','2026-09-29 07:50:21.708321');
INSERT INTO `production_records` VALUES(101,1,2,'2026-08-20',2477,'medium','brown',2.697754616136955974e+02,1.091405706713641849e+03,6.333333333333333037e+00,1,NULL,'2026-09-29 07:50:21.708325','2026-09-29 07:50:21.708329');
INSERT INTO `production_records` VALUES(102,1,2,'2026-08-20',2111,'small','white',297.290071668416,1.098018164759610955e+03,5.5,0,NULL,'2026-09-29 07:50:21.708334','2026-09-29 07:50:21.708338');
INSERT INTO `production_records` VALUES(103,1,2,'2026-08-21',1725,'medium','white',2.868623264876289341e+02,1.029560056292826175e+03,6.166666666666666963e+00,1,NULL,'2026-09-29 07:50:21.708342','2026-09-29 07:50:21.708346');
INSERT INTO `production_records` VALUES(104,1,2,'2026-08-21',2133,'large','white',2.626730315225864273e+02,1.14229677783201214e+03,6.833333333333333037e+00,0,NULL,'2026-09-29 07:50:21.708351','2026-09-29 07:50:21.708355');
INSERT INTO `production_records` VALUES(105,1,2,'2026-08-22',1520,'small','white',2.542973426836440751e+02,1.005522527474978916e+03,5.5,2,NULL,'2026-09-29 07:50:21.708359','2026-09-29 07:50:21.708364');
INSERT INTO `production_records` VALUES(106,1,2,'2026-08-22',2424,'large','brown',2.737514067350023765e+02,1.042122957521138915e+03,7,2,NULL,'2026-09-29 07:50:21.708368','2026-09-29 07:50:21.708372');
INSERT INTO `production_records` VALUES(107,1,2,'2026-08-23',2001,'small','white',2.790645801140390745e+02,1.126317856914813319e+03,5.5,2,NULL,'2026-09-29 07:50:21.708377','2026-09-29 07:50:21.708381');
INSERT INTO `production_records` VALUES(108,1,2,'2026-08-23',1521,'large','white',2.600080967163145828e+02,1.189676283627473595e+03,6.833333333333333037e+00,0,NULL,'2026-09-29 07:50:21.708385','2026-09-29 07:50:21.708389');
INSERT INTO `production_records` VALUES(109,1,2,'2026-08-24',2415,'small','white',2.933499551530077269e+02,1.192377874777003172e+03,5.5,0,NULL,'2026-09-29 07:50:21.708394','2026-09-29 07:50:21.708398');
INSERT INTO `production_records` VALUES(110,1,2,'2026-08-24',1996,'large','brown',2.6120518022075629e+02,1.140433158772891147e+03,7,0,NULL,'2026-09-29 07:50:21.708424','2026-09-29 07:50:21.708430');
INSERT INTO `production_records` VALUES(111,1,2,'2026-08-25',2138,'medium','white',2.566539191815700747e+02,1.044629802150053593e+03,6.166666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708434','2026-09-29 07:50:21.708439');
INSERT INTO `production_records` VALUES(112,1,2,'2026-08-25',2062,'small','brown',2.869827120664811559e+02,1.224703313656903219e+03,5.666666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708443','2026-09-29 07:50:21.708447');
INSERT INTO `production_records` VALUES(113,1,2,'2026-08-26',1902,'small','white',2.973651440349570408e+02,1.03787730955719553e+03,5.5,0,NULL,'2026-09-29 07:50:21.708452','2026-09-29 07:50:21.708456');
INSERT INTO `production_records` VALUES(114,1,2,'2026-08-26',2181,'large','white',2.860400088334818066e+02,1.038045271748775576e+03,6.833333333333333037e+00,2,NULL,'2026-09-29 07:50:21.708460','2026-09-29 07:50:21.708465');
INSERT INTO `production_records` VALUES(115,1,2,'2026-08-27',1772,'large','brown',2.692488061085708182e+02,1.048991221198563153e+03,7,1,NULL,'2026-09-29 07:50:21.708469','2026-09-29 07:50:21.708473');
INSERT INTO `production_records` VALUES(116,1,2,'2026-08-27',2474,'large','white',2.992562658825524977e+02,1.218803558001065084e+03,6.833333333333333037e+00,0,NULL,'2026-09-29 07:50:21.708478','2026-09-29 07:50:21.708482');
INSERT INTO `production_records` VALUES(117,1,2,'2026-08-28',2458,'medium','white',278.463051587756,1.136512477239812597e+03,6.166666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708486','2026-09-29 07:50:21.708490');
INSERT INTO `production_records` VALUES(118,1,2,'2026-08-28',2382,'large','white',2.741233720061846384e+02,1.149837414641247961e+03,6.833333333333333037e+00,1,NULL,'2026-09-29 07:50:21.708495','2026-09-29 07:50:21.708500');
INSERT INTO `production_records` VALUES(119,1,2,'2026-08-29',1550,'small','brown',2.60552402003806776e+02,1.12741706015826776e+03,5.666666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708504','2026-09-29 07:50:21.708508');
INSERT INTO `production_records` VALUES(120,1,2,'2026-08-29',1842,'medium','brown',2.935444027052207048e+02,1.017557954396860168e+03,6.333333333333333037e+00,2,NULL,'2026-09-29 07:50:21.708513','2026-09-29 07:50:21.708517');
INSERT INTO `production_records` VALUES(121,1,2,'2026-08-30',1759,'large','brown',2.810454890323750874e+02,1.090090391083960639e+03,7,2,NULL,'2026-09-29 07:50:21.708521','2026-09-29 07:50:21.708525');
INSERT INTO `production_records` VALUES(122,1,2,'2026-08-30',1621,'medium','brown',2.85233026939715387e+02,1.056574694964254376e+03,6.333333333333333037e+00,1,NULL,'2026-09-29 07:50:21.708530','2026-09-29 07:50:21.708534');
INSERT INTO `production_records` VALUES(123,1,2,'2026-08-31',1500,'large','brown',2.678839365816582472e+02,1.104169659081165947e+03,7,1,NULL,'2026-09-29 07:50:21.708539','2026-09-29 07:50:21.708543');
INSERT INTO `production_records` VALUES(124,1,2,'2026-08-31',2152,'medium','white',2.83253927444871806e+02,1.003551517108425741e+03,6.166666666666666963e+00,0,NULL,'2026-09-29 07:50:21.708547','2026-09-29 07:50:21.708551');
INSERT INTO `production_records` VALUES(125,1,2,'2026-09-01',2211,'large','brown',2.856898192573743244e+02,1.128019630671929007e+03,7,0,NULL,'2026-09-29 07:50:21.708556','2026-09-29 07:50:21.708560');
INSERT INTO `production_records` VALUES(126,1,2,'2026-09-01',2107,'medium','white',2.957163812059145585e+02,1.224830122562947736e+03,6.166666666666666963e+00,1,NULL,'2026-09-29 07:50:21.708564','2026-09-29 07:50:21.708568');
INSERT INTO `production_records` VALUES(127,1,2,'2026-09-02',2109,'small','white',2.84844473359358119e+02,1.06871665378353191e+03,5.5,0,NULL,'2026-09-29 07:50:21.708573','2026-09-29 07:50:21.708577');
INSERT INTO `production_records` VALUES(128,1,2,'2026-09-02',1980,'medium','brown',2.538630293442863604e+02,1.22493239052877243e+03,6.333333333333333037e+00,0,NULL,'2026-09-29 07:50:21.708581','2026-09-29 07:50:21.708586');
INSERT INTO `production_records` VALUES(129,1,2,'2026-09-03',1521,'large','brown',2.629176052491615679e+02,1.167203422844462693e+03,7,2,NULL,'2026-09-29 07:50:21.708590','2026-09-29 07:50:21.708594');
INSERT INTO `production_records` VALUES(130,1,2,'2026-09-03',1568,'small','white',2.526692768104067283e+02,1.037554168811888076e+03,5.5,2,NULL,'2026-09-29 07:50:21.708599','2026-09-29 07:50:21.708603');
INSERT INTO `production_records` VALUES(131,1,2,'2026-09-04',2338,'small','white',2.809747235065992186e+02,1.238194630441968002e+03,5.5,0,NULL,'2026-09-29 07:50:21.708607','2026-09-29 07:50:21.708611');
INSERT INTO `production_records` VALUES(132,1,2,'2026-09-04',1885,'medium','white',2.624483479570075701e+02,1.015440589777250238e+03,6.166666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708616','2026-09-29 07:50:21.708620');
INSERT INTO `production_records` VALUES(133,1,2,'2026-09-05',2050,'medium','brown',2.796414748190620684e+02,1.238545017571303787e+03,6.333333333333333037e+00,0,NULL,'2026-09-29 07:50:21.708624','2026-09-29 07:50:21.708628');
INSERT INTO `production_records` VALUES(134,1,2,'2026-09-05',2262,'medium','white',2.872163959813574365e+02,1.052120055506612289e+03,6.166666666666666963e+00,0,NULL,'2026-09-29 07:50:21.708633','2026-09-29 07:50:21.708637');
INSERT INTO `production_records` VALUES(135,1,2,'2026-09-06',1949,'medium','white',2.874951768963064752e+02,1230.30960135698,6.166666666666666963e+00,0,NULL,'2026-09-29 07:50:21.708641','2026-09-29 07:50:21.708646');
INSERT INTO `production_records` VALUES(136,1,2,'2026-09-06',1568,'medium','brown',2.787420290561013302e+02,1.059740548816862883e+03,6.333333333333333037e+00,2,NULL,'2026-09-29 07:50:21.708650','2026-09-29 07:50:21.708654');
INSERT INTO `production_records` VALUES(137,1,2,'2026-09-07',2009,'large','brown',262.530361407355,1.170145296993860257e+03,7,1,NULL,'2026-09-29 07:50:21.708659','2026-09-29 07:50:21.708663');
INSERT INTO `production_records` VALUES(138,1,2,'2026-09-07',2283,'medium','brown',2.971555701132763829e+02,1.062735266530143691e+03,6.333333333333333037e+00,0,NULL,'2026-09-29 07:50:21.708668','2026-09-29 07:50:21.708672');
INSERT INTO `production_records` VALUES(139,1,2,'2026-09-08',1716,'large','white',2.505714363798514909e+02,1.247643228269574593e+03,6.833333333333333037e+00,2,NULL,'2026-09-29 07:50:21.708676','2026-09-29 07:50:21.708681');
INSERT INTO `production_records` VALUES(140,1,2,'2026-09-08',2251,'medium','brown',2.756937416347959129e+02,1.162180780636028886e+03,6.333333333333333037e+00,2,NULL,'2026-09-29 07:50:21.708685','2026-09-29 07:50:21.708689');
INSERT INTO `production_records` VALUES(141,1,2,'2026-09-09',2320,'medium','brown',2.84941324063421348e+02,1.166909398356410293e+03,6.333333333333333037e+00,2,NULL,'2026-09-29 07:50:21.708694','2026-09-29 07:50:21.708698');
INSERT INTO `production_records` VALUES(142,1,2,'2026-09-09',2377,'large','brown',2.687325119440707794e+02,1.022127336216500225e+03,7,0,NULL,'2026-09-29 07:50:21.708702','2026-09-29 07:50:21.708706');
INSERT INTO `production_records` VALUES(143,1,2,'2026-09-10',2424,'small','brown',2.897229520597254009e+02,1.025032096704380592e+03,5.666666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708711','2026-09-29 07:50:21.708715');
INSERT INTO `production_records` VALUES(144,1,2,'2026-09-10',2165,'large','brown',2.740636906772912766e+02,1.169421306005686346e+03,7,0,NULL,'2026-09-29 07:50:21.708719','2026-09-29 07:50:21.708724');
INSERT INTO `production_records` VALUES(145,1,2,'2026-09-11',2289,'medium','white',2.767835489679207512e+02,1.104012749116114037e+03,6.166666666666666963e+00,0,NULL,'2026-09-29 07:50:21.708728','2026-09-29 07:50:21.708732');
INSERT INTO `production_records` VALUES(146,1,2,'2026-09-11',1506,'small','brown',2.638582269044615601e+02,1.173325069537689614e+03,5.666666666666666963e+00,1,NULL,'2026-09-29 07:50:21.708736','2026-09-29 07:50:21.708741');
INSERT INTO `production_records` VALUES(147,1,2,'2026-09-12',2423,'small','white',2.744053240794814883e+02,1.113392489949650554e+03,5.5,0,NULL,'2026-09-29 07:50:21.708745','2026-09-29 07:50:21.708749');
INSERT INTO `production_records` VALUES(148,1,2,'2026-09-12',2078,'medium','white',2.611174927055781723e+02,1.211339072102207638e+03,6.166666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708754','2026-09-29 07:50:21.708758');
INSERT INTO `production_records` VALUES(149,1,2,'2026-09-13',2476,'medium','brown',2.717660715982084981e+02,1.235075370406051207e+03,6.333333333333333037e+00,1,NULL,'2026-09-29 07:50:21.708762','2026-09-29 07:50:21.708766');
INSERT INTO `production_records` VALUES(150,1,2,'2026-09-13',1569,'small','brown',2.853500545807006575e+02,1.008448153198261594e+03,5.666666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708771','2026-09-29 07:50:21.708775');
INSERT INTO `production_records` VALUES(151,1,2,'2026-09-14',2064,'small','white',2.97927533124172328e+02,1.127866611707631136e+03,5.5,1,NULL,'2026-09-29 07:50:21.708780','2026-09-29 07:50:21.708784');
INSERT INTO `production_records` VALUES(152,1,2,'2026-09-14',1575,'small','brown',2.809678952840807825e+02,1.068185247500198784e+03,5.666666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708788','2026-09-29 07:50:21.708792');
INSERT INTO `production_records` VALUES(153,1,2,'2026-09-15',1623,'medium','brown',2.576573512024636443e+02,1.239535195937956815e+03,6.333333333333333037e+00,0,NULL,'2026-09-29 07:50:21.708797','2026-09-29 07:50:21.708801');
INSERT INTO `production_records` VALUES(154,1,2,'2026-09-15',2438,'large','white',2.845166202799452436e+02,1.235025454487765956e+03,6.833333333333333037e+00,1,NULL,'2026-09-29 07:50:21.708805','2026-09-29 07:50:21.708809');
INSERT INTO `production_records` VALUES(155,1,2,'2026-09-16',1624,'large','brown',2.826680672781166094e+02,1.179867236366482757e+03,7,0,NULL,'2026-09-29 07:50:21.708814','2026-09-29 07:50:21.708818');
INSERT INTO `production_records` VALUES(156,1,2,'2026-09-16',2345,'small','brown',2.629138624584273317e+02,1.210468987562973552e+03,5.666666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708823','2026-09-29 07:50:21.708827');
INSERT INTO `production_records` VALUES(157,1,2,'2026-09-17',1699,'medium','white',263.695425499781,1.198012482151467338e+03,6.166666666666666963e+00,1,NULL,'2026-09-29 07:50:21.708831','2026-09-29 07:50:21.708835');
INSERT INTO `production_records` VALUES(158,1,2,'2026-09-17',2029,'large','white',2.971270581092354632e+02,1.156093273877183264e+03,6.833333333333333037e+00,0,NULL,'2026-09-29 07:50:21.708840','2026-09-29 07:50:21.708844');
INSERT INTO `production_records` VALUES(159,1,2,'2026-09-18',2401,'medium','white',2.851022795782538423e+02,1.079149541466073061e+03,6.166666666666666963e+00,1,NULL,'2026-09-29 07:50:21.708848','2026-09-29 07:50:21.708852');
INSERT INTO `production_records` VALUES(160,1,2,'2026-09-18',2096,'large','brown',2.531774812855557571e+02,1.00744152040804147e+03,7,1,NULL,'2026-09-29 07:50:21.708857','2026-09-29 07:50:21.708861');
INSERT INTO `production_records` VALUES(161,1,2,'2026-09-19',1520,'medium','brown',2.705459462906405861e+02,1.147278285047586223e+03,6.333333333333333037e+00,2,NULL,'2026-09-29 07:50:21.708866','2026-09-29 07:50:21.708870');
INSERT INTO `production_records` VALUES(162,1,2,'2026-09-19',1617,'medium','white',2.762766110221128883e+02,1.124955978258723234e+03,6.166666666666666963e+00,0,NULL,'2026-09-29 07:50:21.708875','2026-09-29 07:50:21.708879');
INSERT INTO `production_records` VALUES(163,1,2,'2026-09-20',1939,'large','brown',2.964792966711518716e+02,1.040299264941465936e+03,7,0,NULL,'2026-09-29 07:50:21.708883','2026-09-29 07:50:21.708888');
INSERT INTO `production_records` VALUES(164,1,2,'2026-09-20',1888,'large','white',2.568957956596837561e+02,1.099147131875829246e+03,6.833333333333333037e+00,2,NULL,'2026-09-29 07:50:21.708892','2026-09-29 07:50:21.708896');
INSERT INTO `production_records` VALUES(165,1,2,'2026-09-21',1566,'small','white',2.690040842882845596e+02,1.182536361906321873e+03,5.5,2,NULL,'2026-09-29 07:50:21.708901','2026-09-29 07:50:21.708905');
INSERT INTO `production_records` VALUES(166,1,2,'2026-09-21',1679,'small','brown',268.103086833495,1.192999058547036612e+03,5.666666666666666963e+00,0,NULL,'2026-09-29 07:50:21.708909','2026-09-29 07:50:21.708913');
INSERT INTO `production_records` VALUES(167,1,2,'2026-09-22',1657,'medium','brown',2.967069672584927957e+02,1.226642333911642936e+03,6.333333333333333037e+00,0,NULL,'2026-09-29 07:50:21.708918','2026-09-29 07:50:21.708922');
INSERT INTO `production_records` VALUES(168,1,2,'2026-09-22',1955,'large','white',2.60358663661386288e+02,1.191661782730145206e+03,6.833333333333333037e+00,2,NULL,'2026-09-29 07:50:21.708926','2026-09-29 07:50:21.708930');
INSERT INTO `production_records` VALUES(169,1,2,'2026-09-23',1554,'medium','brown',2.679181724884321057e+02,1.071444842572910602e+03,6.333333333333333037e+00,1,NULL,'2026-09-29 07:50:21.708935','2026-09-29 07:50:21.708939');
INSERT INTO `production_records` VALUES(170,1,2,'2026-09-23',2321,'large','brown',298.591114560902,1.193055393438738974e+03,7,2,NULL,'2026-09-29 07:50:21.708944','2026-09-29 07:50:21.708948');
INSERT INTO `production_records` VALUES(171,1,2,'2026-09-24',2223,'large','brown',2.609032830061718755e+02,1.249177496849208637e+03,7,0,NULL,'2026-09-29 07:50:21.708952','2026-09-29 07:50:21.708956');
INSERT INTO `production_records` VALUES(172,1,2,'2026-09-24',2003,'small','brown',2.578464239087883811e+02,1.105082695115294654e+03,5.666666666666666963e+00,1,NULL,'2026-09-29 07:50:21.708961','2026-09-29 07:50:21.708965');
INSERT INTO `production_records` VALUES(173,1,2,'2026-09-25',1669,'medium','white',2.872161103455642319e+02,1.222159395561013753e+03,6.166666666666666963e+00,2,NULL,'2026-09-29 07:50:21.708969','2026-09-29 07:50:21.708974');
INSERT INTO `production_records` VALUES(174,1,2,'2026-09-25',1873,'small','brown',2.962585244430749185e+02,1.080557320837195903e+03,5.666666666666666963e+00,1,NULL,'2026-09-29 07:50:21.708978','2026-09-29 07:50:21.708982');
INSERT INTO `production_records` VALUES(175,1,2,'2026-09-26',1967,'medium','brown',2.745890264436923758e+02,1.026513651579562748e+03,6.333333333333333037e+00,1,NULL,'2026-09-29 07:50:21.708987','2026-09-29 07:50:21.708991');
INSERT INTO `production_records` VALUES(176,1,2,'2026-09-26',2332,'large','white',295.153587716684,1.197376963384851251e+03,6.833333333333333037e+00,0,NULL,'2026-09-29 07:50:21.708995','2026-09-29 07:50:21.708999');
INSERT INTO `production_records` VALUES(177,1,2,'2026-09-27',1618,'medium','white',2.552597768092126103e+02,1.051128065468733667e+03,6.166666666666666963e+00,0,NULL,'2026-09-29 07:50:21.709004','2026-09-29 07:50:21.709008');
INSERT INTO `production_records` VALUES(178,1,2,'2026-09-27',1839,'large','brown',2.720048214400753749e+02,1.135799966085740607e+03,7,1,NULL,'2026-09-29 07:50:21.709012','2026-09-29 07:50:21.709017');
INSERT INTO `production_records` VALUES(179,1,2,'2026-09-28',2429,'medium','white',2.995709067087883569e+02,1.099471881829344739e+03,6.166666666666666963e+00,1,NULL,'2026-09-29 07:50:21.709021','2026-09-29 07:50:21.709025');
INSERT INTO `production_records` VALUES(180,1,2,'2026-09-28',2186,'small','brown',2.746320074778039384e+02,1.01427828510193899e+03,5.666666666666666963e+00,1,NULL,'2026-09-29 07:50:21.709030','2026-09-29 07:50:21.709034');
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
INSERT INTO `products` VALUES(1,2,1,'Fresh Brown Eggs (Small)','Freshly harvested small brown eggs.','small','brown','tray',170,100,NULL,1,'2026-09-29 07:50:21.565475','2026-09-29 07:50:21.565485',NULL,'pending');
INSERT INTO `products` VALUES(2,2,1,'Fresh Brown Eggs (Medium)','Freshly harvested medium brown eggs.','medium','brown','tray',190,300,NULL,1,'2026-09-29 07:50:21.565492','2026-09-29 07:50:21.565496',NULL,'pending');
INSERT INTO `products` VALUES(3,2,1,'Fresh Brown Eggs (Large)','Freshly harvested large brown eggs.','large','brown','tray',210,200,NULL,1,'2026-09-29 07:50:21.565501','2026-09-29 07:50:21.565506',NULL,'pending');
INSERT INTO `products` VALUES(4,2,1,'Fresh White Eggs (Small)','Freshly harvested small white eggs.','small','white','tray',165,120,NULL,1,'2026-09-29 07:50:21.565511','2026-09-29 07:50:21.565515',NULL,'pending');
INSERT INTO `products` VALUES(5,2,1,'Fresh White Eggs (Medium)','Freshly harvested medium white eggs.','medium','white','tray',185,250,NULL,1,'2026-09-29 07:50:21.565520','2026-09-29 07:50:21.565525',NULL,'pending');
INSERT INTO `products` VALUES(6,2,1,'Fresh White Eggs (Large)','Freshly harvested large white eggs.','large','white','tray',205,180,NULL,1,'2026-09-29 07:50:21.565531','2026-09-29 07:50:21.565538',NULL,'pending');
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
INSERT INTO `sales_records` VALUES(1,1,2,'2026-07-12',600,5.666666666666666963e+00,3400,'Maria Reyes',NULL,'2026-07-12 15:00:00.000000','2026-09-29 07:50:21.734197');
INSERT INTO `sales_records` VALUES(2,1,2,'2026-07-08',750,6.333333333333333037e+00,4750,'Maria Reyes',NULL,'2026-07-08 13:00:00.000000','2026-09-29 07:50:21.740814');
INSERT INTO `sales_records` VALUES(3,1,2,'2026-08-09',1080,5.5,5940,'Maria Reyes',NULL,'2026-08-09 09:00:00.000000','2026-09-29 07:50:21.744477');
INSERT INTO `sales_records` VALUES(4,1,2,'2026-08-08',300,6.833333333333333037e+00,2050,'Maria Reyes',NULL,'2026-08-08 09:00:00.000000','2026-09-29 07:50:21.747973');
INSERT INTO `sales_records` VALUES(5,1,2,'2026-07-18',1260,5.666666666666666963e+00,7140,'Maria Reyes',NULL,'2026-07-18 17:00:00.000000','2026-09-29 07:50:21.750868');
INSERT INTO `sales_records` VALUES(6,1,2,'2026-07-18',1080,5.5,5940,'Maria Reyes',NULL,'2026-07-18 08:00:00.000000','2026-09-29 07:50:21.753251');
INSERT INTO `sales_records` VALUES(7,1,2,'2026-07-05',1050,6.833333333333333037e+00,7175,'Maria Reyes',NULL,'2026-07-05 16:00:00.000000','2026-09-29 07:50:21.755487');
INSERT INTO `sales_records` VALUES(8,1,2,'2026-07-04',390,5.666666666666666963e+00,2210,'Maria Reyes',NULL,'2026-07-04 10:00:00.000000','2026-09-29 07:50:21.757944');
INSERT INTO `sales_records` VALUES(9,1,2,'2026-08-01',1290,6.166666666666666963e+00,7955,'Maria Reyes',NULL,'2026-08-01 12:00:00.000000','2026-09-29 07:50:21.761083');
INSERT INTO `sales_records` VALUES(10,1,2,'2026-07-23',600,5.666666666666666963e+00,3400,'Maria Reyes',NULL,'2026-07-23 18:00:00.000000','2026-09-29 07:50:21.764390');
INSERT INTO `sales_records` VALUES(11,1,2,'2026-08-13',810,6.333333333333333037e+00,5130,'Maria Reyes',NULL,'2026-08-13 09:00:00.000000','2026-09-29 07:50:21.767920');
INSERT INTO `sales_records` VALUES(12,1,2,'2026-09-22',780,6.333333333333333037e+00,4940,'Maria Reyes',NULL,'2026-09-22 17:00:00.000000','2026-09-29 07:50:21.771238');
INSERT INTO `sales_records` VALUES(13,1,2,'2026-07-31',150,5.5,825,'Maria Reyes',NULL,'2026-07-31 13:00:00.000000','2026-09-29 07:50:21.774272');
INSERT INTO `sales_records` VALUES(14,1,2,'2026-07-20',150,5.666666666666666963e+00,850,'Maria Reyes',NULL,'2026-07-20 15:00:00.000000','2026-09-29 07:50:21.777730');
INSERT INTO `sales_records` VALUES(15,1,2,'2026-07-02',450,6.833333333333333037e+00,3075,'Maria Reyes',NULL,'2026-07-02 09:00:00.000000','2026-09-29 07:50:21.780852');
INSERT INTO `sales_records` VALUES(16,1,2,'2026-07-25',990,6.166666666666666963e+00,6105,'Maria Reyes',NULL,'2026-07-25 14:00:00.000000','2026-09-29 07:50:21.784180');
INSERT INTO `sales_records` VALUES(17,1,2,'2026-09-16',420,7,2940,'Maria Reyes',NULL,'2026-09-16 08:00:00.000000','2026-09-29 07:50:21.787408');
INSERT INTO `sales_records` VALUES(18,1,2,'2026-07-16',780,6.166666666666666963e+00,4810,'Maria Reyes',NULL,'2026-07-16 17:00:00.000000','2026-09-29 07:50:21.790667');
INSERT INTO `sales_records` VALUES(19,1,2,'2026-09-17',1200,5.5,6600,'Maria Reyes',NULL,'2026-09-17 17:00:00.000000','2026-09-29 07:50:21.794639');
INSERT INTO `sales_records` VALUES(20,1,2,'2026-09-13',840,5.666666666666666963e+00,4760,'Maria Reyes',NULL,'2026-09-13 11:00:00.000000','2026-09-29 07:50:21.797777');
INSERT INTO `sales_records` VALUES(21,1,2,'2026-07-31',630,6.166666666666666963e+00,3885,'Maria Reyes',NULL,'2026-07-31 09:00:00.000000','2026-09-29 07:50:21.800997');
INSERT INTO `sales_records` VALUES(22,1,2,'2026-07-12',810,5.5,4455,'Maria Reyes',NULL,'2026-07-12 08:00:00.000000','2026-09-29 07:50:21.804945');
INSERT INTO `sales_records` VALUES(23,1,2,'2026-07-10',330,5.666666666666666963e+00,1870,'Maria Reyes',NULL,'2026-07-10 13:00:00.000000','2026-09-29 07:50:21.808373');
INSERT INTO `sales_records` VALUES(24,1,2,'2026-09-06',1260,6.833333333333333037e+00,8610,'Maria Reyes',NULL,'2026-09-06 11:00:00.000000','2026-09-29 07:50:21.811076');
INSERT INTO `sales_records` VALUES(25,1,2,'2026-07-11',240,7,1680,'Maria Reyes',NULL,'2026-07-11 18:00:00.000000','2026-09-29 07:50:21.814329');
INSERT INTO `sales_records` VALUES(26,1,2,'2026-09-09',720,6.166666666666666963e+00,4440,'Maria Reyes',NULL,'2026-09-09 15:00:00.000000','2026-09-29 07:50:21.817570');
INSERT INTO `sales_records` VALUES(27,1,2,'2026-07-22',1320,6.333333333333333037e+00,8360,'Maria Reyes',NULL,'2026-07-22 10:00:00.000000','2026-09-29 07:50:21.820567');
INSERT INTO `sales_records` VALUES(28,1,2,'2026-08-15',720,6.166666666666666963e+00,4440,'Maria Reyes',NULL,'2026-08-15 15:00:00.000000','2026-09-29 07:50:21.823931');
INSERT INTO `sales_records` VALUES(29,1,2,'2026-07-01',660,5.666666666666666963e+00,3740,'Maria Reyes',NULL,'2026-07-01 16:00:00.000000','2026-09-29 07:50:21.827908');
INSERT INTO `sales_records` VALUES(30,1,2,'2026-09-07',450,6.333333333333333037e+00,2850,'Maria Reyes',NULL,'2026-09-07 14:00:00.000000','2026-09-29 07:50:21.830016');
INSERT INTO `sales_records` VALUES(31,1,2,'2026-08-10',1470,5.5,8085,'Maria Reyes',NULL,'2026-08-10 17:00:00.000000','2026-09-29 07:50:21.833061');
INSERT INTO `sales_records` VALUES(32,1,2,'2026-09-18',450,5.5,2475,'Maria Reyes',NULL,'2026-09-18 15:00:00.000000','2026-09-29 07:50:21.835470');
INSERT INTO `sales_records` VALUES(33,1,2,'2026-07-05',870,6.166666666666666963e+00,5365,'Maria Reyes',NULL,'2026-07-05 13:00:00.000000','2026-09-29 07:50:21.837598');
INSERT INTO `sales_records` VALUES(34,1,2,'2026-09-05',570,6.333333333333333037e+00,3610,'Maria Reyes',NULL,'2026-09-05 15:00:00.000000','2026-09-29 07:50:21.839717');
INSERT INTO `sales_records` VALUES(35,1,2,'2026-09-16',1470,5.666666666666666963e+00,8330,'Maria Reyes',NULL,'2026-09-16 08:00:00.000000','2026-09-29 07:50:21.842087');
INSERT INTO `sales_records` VALUES(36,1,2,'2026-07-17',510,6.333333333333333037e+00,3230,'Maria Reyes',NULL,'2026-07-17 16:00:00.000000','2026-09-29 07:50:21.845336');
INSERT INTO `sales_records` VALUES(37,1,2,'2026-08-13',900,6.833333333333333037e+00,6150,'Maria Reyes',NULL,'2026-08-13 16:00:00.000000','2026-09-29 07:50:21.848521');
INSERT INTO `sales_records` VALUES(38,1,2,'2026-07-07',990,5.666666666666666963e+00,5610,'Maria Reyes',NULL,'2026-07-07 18:00:00.000000','2026-09-29 07:50:21.851487');
INSERT INTO `sales_records` VALUES(39,1,2,'2026-09-22',330,7,2310,'Maria Reyes',NULL,'2026-09-22 11:00:00.000000','2026-09-29 07:50:21.853778');
INSERT INTO `sales_records` VALUES(40,1,2,'2026-09-09',510,5.666666666666666963e+00,2890,'Maria Reyes',NULL,'2026-09-09 11:00:00.000000','2026-09-29 07:50:21.856083');
INSERT INTO `sales_records` VALUES(41,1,2,'2026-08-13',600,6.833333333333333037e+00,4100,'Maria Reyes',NULL,'2026-08-13 11:00:00.000000','2026-09-29 07:50:21.858355');
INSERT INTO `sales_records` VALUES(42,1,2,'2026-08-12',1410,5.666666666666666963e+00,7990,'Maria Reyes',NULL,'2026-08-12 14:00:00.000000','2026-09-29 07:50:21.861643');
INSERT INTO `sales_records` VALUES(43,1,2,'2026-09-05',750,6.833333333333333037e+00,5125,'Maria Reyes',NULL,'2026-09-05 12:00:00.000000','2026-09-29 07:50:21.864873');
INSERT INTO `sales_records` VALUES(44,1,2,'2026-07-11',150,5.666666666666666963e+00,850,'Maria Reyes',NULL,'2026-07-11 15:00:00.000000','2026-09-29 07:50:21.867974');
INSERT INTO `sales_records` VALUES(45,1,2,'2026-07-06',1020,6.166666666666666963e+00,6290,'Maria Reyes',NULL,'2026-07-06 08:00:00.000000','2026-09-29 07:50:21.870344');
INSERT INTO `sales_records` VALUES(46,1,2,'2026-08-25',1170,5.5,6435,'Maria Reyes',NULL,'2026-08-25 12:00:00.000000','2026-09-29 07:50:21.872480');
INSERT INTO `sales_records` VALUES(47,1,2,'2026-07-07',690,6.833333333333333037e+00,4715,'Maria Reyes',NULL,'2026-07-07 17:00:00.000000','2026-09-29 07:50:21.874576');
INSERT INTO `sales_records` VALUES(48,1,2,'2026-09-17',480,5.666666666666666963e+00,2720,'Maria Reyes',NULL,'2026-09-17 18:00:00.000000','2026-09-29 07:50:21.877016');
INSERT INTO `sales_records` VALUES(49,1,2,'2026-09-21',750,6.333333333333333037e+00,4750,'Maria Reyes',NULL,'2026-09-21 16:00:00.000000','2026-09-29 07:50:21.879215');
INSERT INTO `sales_records` VALUES(50,1,2,'2026-08-07',300,6.333333333333333037e+00,1900,'Maria Reyes',NULL,'2026-08-07 13:00:00.000000','2026-09-29 07:50:21.881908');
INSERT INTO `sales_records` VALUES(51,1,2,'2026-08-15',1260,6.833333333333333037e+00,8610,'Maria Reyes',NULL,'2026-08-15 18:00:00.000000','2026-09-29 07:50:21.884599');
INSERT INTO `sales_records` VALUES(52,1,2,'2026-07-05',300,7,2100,'Maria Reyes',NULL,'2026-07-05 13:00:00.000000','2026-09-29 07:50:21.886769');
INSERT INTO `sales_records` VALUES(53,1,2,'2026-08-27',1380,7,9660,'Maria Reyes',NULL,'2026-08-27 13:00:00.000000','2026-09-29 07:50:21.888870');
INSERT INTO `sales_records` VALUES(54,1,2,'2026-08-28',630,6.166666666666666963e+00,3885,'Maria Reyes',NULL,'2026-08-28 08:00:00.000000','2026-09-29 07:50:21.890966');
INSERT INTO `sales_records` VALUES(55,1,2,'2026-07-31',1320,6.333333333333333037e+00,8360,'Maria Reyes',NULL,'2026-07-31 17:00:00.000000','2026-09-29 07:50:21.893473');
INSERT INTO `sales_records` VALUES(56,1,2,'2026-08-06',1350,6.833333333333333037e+00,9225,'Maria Reyes',NULL,'2026-08-06 18:00:00.000000','2026-09-29 07:50:21.895592');
INSERT INTO `sales_records` VALUES(57,1,2,'2026-07-25',450,7,3150,'Maria Reyes',NULL,'2026-07-25 11:00:00.000000','2026-09-29 07:50:21.898247');
INSERT INTO `sales_records` VALUES(58,1,2,'2026-07-24',570,7,3990,'Maria Reyes',NULL,'2026-07-24 09:00:00.000000','2026-09-29 07:50:21.900967');
INSERT INTO `sales_records` VALUES(59,1,2,'2026-08-03',720,6.333333333333333037e+00,4560,'Maria Reyes',NULL,'2026-08-03 15:00:00.000000','2026-09-29 07:50:21.903100');
INSERT INTO `sales_records` VALUES(60,1,2,'2026-09-13',1170,6.333333333333333037e+00,7410,'Maria Reyes',NULL,'2026-09-13 08:00:00.000000','2026-09-29 07:50:21.905203');
INSERT INTO `sales_records` VALUES(61,1,2,'2026-07-17',240,5.5,1320,'Maria Reyes',NULL,'2026-07-17 08:00:00.000000','2026-09-29 07:50:21.907569');
INSERT INTO `sales_records` VALUES(62,1,2,'2026-09-14',330,5.666666666666666963e+00,1870,'Maria Reyes',NULL,'2026-09-14 11:00:00.000000','2026-09-29 07:50:21.910525');
INSERT INTO `sales_records` VALUES(63,1,2,'2026-08-17',1050,6.166666666666666963e+00,6475,'Maria Reyes',NULL,'2026-08-17 09:00:00.000000','2026-09-29 07:50:21.912696');
INSERT INTO `sales_records` VALUES(64,1,2,'2026-07-30',810,6.333333333333333037e+00,5130,'Maria Reyes',NULL,'2026-07-30 17:00:00.000000','2026-09-29 07:50:21.915060');
INSERT INTO `sales_records` VALUES(65,1,2,'2026-08-09',720,6.166666666666666963e+00,4440,'Maria Reyes',NULL,'2026-08-09 10:00:00.000000','2026-09-29 07:50:21.918013');
INSERT INTO `sales_records` VALUES(66,1,2,'2026-08-31',720,6.833333333333333037e+00,4920,'Maria Reyes',NULL,'2026-08-31 16:00:00.000000','2026-09-29 07:50:21.920207');
INSERT INTO `sales_records` VALUES(67,1,2,'2026-07-23',630,5.666666666666666963e+00,3570,'Maria Reyes',NULL,'2026-07-23 08:00:00.000000','2026-09-29 07:50:21.922322');
INSERT INTO `sales_records` VALUES(68,1,2,'2026-07-03',990,5.5,5445,'Maria Reyes',NULL,'2026-07-03 15:00:00.000000','2026-09-29 07:50:21.924422');
INSERT INTO `sales_records` VALUES(69,1,2,'2026-09-18',930,6.833333333333333037e+00,6355,'Maria Reyes',NULL,'2026-09-18 17:00:00.000000','2026-09-29 07:50:21.926448');
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
	updated_at DATETIME NOT NULL, subscription_plan VARCHAR(7) DEFAULT 'free' NOT NULL, subscription_end DATETIME, trial_end DATETIME, 
	PRIMARY KEY (id)
);
INSERT INTO `users` VALUES(1,'admin','admin@poultryconnect.com','scrypt:32768:8:1$IIdRogA4aPBSh6fU$d00ed1353e97632bb89fd164260901fb01407b18126a10e6b03c42172ec79434a89170890f2690c9cdc7afaf4bc0acb6c11f534bf28dbbac0b518b554d7f4b79','admin','System','Admin','09170000000',NULL,NULL,1,1,'2026-09-30 05:31:15.015715','2026-09-29 07:50:21.481210','2026-09-30 05:31:15.018357','free',NULL,'2026-10-06 07:50:21.481210');
INSERT INTO `users` VALUES(2,'jdelacruz','farmer@poultryconnect.com','scrypt:32768:8:1$DBi3fZQVyoESCyM0$48b1c21a6fcb323b27f53c50c9e06d8bd6471751639a85de8a558c8957a0f3bda96be80a809ba1ccbf5b76731b86bce24df722fb8b84ae5e303acb68cc685f74','farmer','Juan','Dela Cruz','09171234567',NULL,NULL,1,0,'2026-09-30 06:08:03.513319','2026-09-29 07:50:21.481242','2026-09-30 06:08:03.514978','free',NULL,'2026-09-30 05:59:41.155600');
INSERT INTO `users` VALUES(3,'mreyes','buyer@poultryconnect.com','scrypt:32768:8:1$IUXbvijcdlRuBdx7$9b898f6d89bb20593c9392da04a896985bd0bbc38316cd070450930843489e5bae80cd379dfc47cef55954f5f4651d969f2dc9982fa9be5bc725e937d9d3d62f','buyer','Maria','Reyes','09189876543',NULL,NULL,1,1,'2026-09-30 06:08:18.107847','2026-09-29 07:50:21.481253','2026-09-30 06:08:18.109753','free',NULL,'2026-10-06 07:50:21.481253');
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
CREATE INDEX ix_buyer_feedback_farmer_id ON buyer_feedback (farmer_id);
CREATE INDEX ix_buyer_feedback_product_id ON buyer_feedback (product_id);

SET foreign_key_checks = 1;
