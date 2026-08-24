-- =====================================================================
-- HireHive / find-my-interview -- MySQL schema: `recruitment_system`
--
-- REGENERATED from the LIVE database on 2026-08-19.
-- The previous version of this file was a stale dump that (a) omitted 7
-- tables the application actually queries and (b) contained real personal
-- data. Both problems are fixed here.
--
-- Seed data below is SYNTHETIC except for the assessment / badge content,
-- which is application content rather than user data.
--
-- NOTE: this file documents the LEGACY MySQL schema. It is kept for
-- reference during the FastAPI/PostgreSQL migration. Once Alembic owns the
-- schema, this file becomes historical -- do not hand-edit the live DB.
--
-- Known gap: the application's notes API (POST/GET/DELETE /api/notes)
-- queries a `company_notes` table that does NOT exist in this schema.
-- That feature is broken at runtime. See docs/legacy_api.md.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `recruitment_system`
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `recruitment_system`;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `assessment_questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assessment_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `assessment_id` int NOT NULL,
  `question_text` text NOT NULL,
  `option_a` varchar(500) NOT NULL,
  `option_b` varchar(500) NOT NULL,
  `option_c` varchar(500) NOT NULL,
  `option_d` varchar(500) NOT NULL,
  `correct_answer` int NOT NULL COMMENT '0=A, 1=B, 2=C, 3=D',
  `explanation` text,
  `difficulty` enum('easy','medium','hard') DEFAULT 'medium',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `assessment_id` (`assessment_id`),
  CONSTRAINT `fk_questions_assessment` FOREIGN KEY (`assessment_id`) REFERENCES `assessments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `assessments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assessments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `category` enum('aptitude','coding','technical','behavioral') NOT NULL,
  `difficulty` enum('easy','medium','hard') NOT NULL,
  `duration` int NOT NULL COMMENT 'Duration in minutes',
  `passing_score` int NOT NULL DEFAULT '70',
  `question_count` int NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `auth_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('hr','interviewer','candidate') NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `availability_slots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `availability_slots` (
  `id` int NOT NULL AUTO_INCREMENT,
  `interviewer_id` int NOT NULL,
  `day_of_week` enum('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  PRIMARY KEY (`id`),
  KEY `interviewer_id` (`interviewer_id`),
  CONSTRAINT `availability_slots_ibfk_1` FOREIGN KEY (`interviewer_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `badges` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `icon` varchar(50) NOT NULL,
  `criteria` varchar(255) NOT NULL COMMENT 'Criteria to earn the badge',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `candidate_assessment_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidate_assessment_results` (
  `id` int NOT NULL AUTO_INCREMENT,
  `candidate_id` int NOT NULL,
  `assessment_id` int NOT NULL,
  `score` decimal(5,2) NOT NULL,
  `correct_answers` int NOT NULL,
  `incorrect_answers` int NOT NULL,
  `time_taken` int NOT NULL COMMENT 'Time in minutes',
  `passed` tinyint(1) NOT NULL,
  `answers` json DEFAULT NULL COMMENT 'Array of selected answer indices',
  `completed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `candidate_id` (`candidate_id`),
  KEY `assessment_id` (`assessment_id`),
  CONSTRAINT `fk_results_assessment` FOREIGN KEY (`assessment_id`) REFERENCES `assessments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_results_candidate` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `candidate_badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidate_badges` (
  `id` int NOT NULL AUTO_INCREMENT,
  `candidate_id` int NOT NULL,
  `badge_id` int NOT NULL,
  `earned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_candidate_badge` (`candidate_id`,`badge_id`),
  KEY `candidate_id` (`candidate_id`),
  KEY `badge_id` (`badge_id`),
  CONSTRAINT `fk_cbadges_badge` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cbadges_candidate` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `candidates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `position` varchar(255) DEFAULT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `education` varchar(255) DEFAULT NULL,
  `experience_years` int DEFAULT NULL,
  `skills` text,
  `location` varchar(255) DEFAULT NULL,
  `resume_file_name` varchar(255) DEFAULT NULL,
  `resume_file_path` varchar(500) DEFAULT NULL,
  `notes` text,
  `password` varchar(225) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `company_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_candidate_company` (`company_id`),
  CONSTRAINT `fk_candidate_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `candidates_chk_1` CHECK ((`experience_years` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `companies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `industry` varchar(100) NOT NULL,
  `registration_number` varchar(100) NOT NULL,
  `gstin` varchar(30) DEFAULT NULL,
  `official_email` varchar(150) NOT NULL,
  `website` varchar(255) DEFAULT NULL,
  `contact_number` varchar(20) NOT NULL,
  `company_size` varchar(50) NOT NULL,
  `address` text NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `logo_file_name` varchar(255) DEFAULT NULL,
  `logo_file_path` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `registration_number` (`registration_number`),
  UNIQUE KEY `official_email` (`official_email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `company_id` (`company_id`),
  CONSTRAINT `departments_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `department_id` int NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `username` varchar(100) NOT NULL,
  `role` enum('hr','interviewer') NOT NULL,
  `auth_user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `auth_user_id` (`auth_user_id`),
  KEY `company_id` (`company_id`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `employees_ibfk_2` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `interview_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `interview_feedback` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `interview_id` int NOT NULL,
  `candidate_id` int NOT NULL,
  `candidate_name` varchar(255) NOT NULL,
  `position` varchar(255) NOT NULL,
  `interviewer_name` varchar(255) NOT NULL,
  `interview_date` datetime NOT NULL,
  `technical_skills` int NOT NULL,
  `technical_comments` text,
  `communication_skills` int NOT NULL,
  `communication_comments` text,
  `problem_solving` int NOT NULL,
  `problem_solving_comments` text,
  `cultural_fit` int NOT NULL,
  `cultural_fit_comments` text,
  `leadership_potential` int NOT NULL,
  `leadership_comments` text,
  `overall_rating` int NOT NULL,
  `strengths` text,
  `weaknesses` text,
  `additional_notes` text,
  `recommendation` enum('strongly_recommend','recommend','neutral','not_recommend','strongly_not_recommend') NOT NULL,
  `requires_followup` tinyint(1) DEFAULT '0',
  `followup_notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `company_id` (`company_id`),
  KEY `interview_id` (`interview_id`),
  KEY `candidate_id` (`candidate_id`),
  CONSTRAINT `feedback_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feedback_ibfk_2` FOREIGN KEY (`interview_id`) REFERENCES `interviews` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feedback_ibfk_3` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feedback_chk_1` CHECK (((`technical_skills` >= 0) and (`technical_skills` <= 10))),
  CONSTRAINT `feedback_chk_2` CHECK (((`communication_skills` >= 0) and (`communication_skills` <= 10))),
  CONSTRAINT `feedback_chk_3` CHECK (((`problem_solving` >= 0) and (`problem_solving` <= 10))),
  CONSTRAINT `feedback_chk_4` CHECK (((`cultural_fit` >= 0) and (`cultural_fit` <= 10))),
  CONSTRAINT `feedback_chk_5` CHECK (((`leadership_potential` >= 0) and (`leadership_potential` <= 10))),
  CONSTRAINT `feedback_chk_6` CHECK (((`overall_rating` >= 1) and (`overall_rating` <= 5)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `interviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `interviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `candidate_id` int NOT NULL,
  `candidate_name` varchar(255) NOT NULL,
  `position` varchar(255) DEFAULT NULL,
  `round` varchar(100) DEFAULT NULL,
  `interviewer_1` varchar(255) DEFAULT NULL,
  `interviewer_2` varchar(255) DEFAULT NULL,
  `interviewer_3` varchar(255) DEFAULT NULL,
  `interview_date` datetime NOT NULL,
  `interview_link` varchar(500) DEFAULT NULL,
  `interview_location` varchar(255) DEFAULT NULL,
  `notes` text,
  `status` enum('scheduled','completed','canceled','pending') DEFAULT 'scheduled',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `company_id` (`company_id`),
  KEY `candidate_id` (`candidate_id`),
  CONSTRAINT `interviews_ibfk_candidate` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE CASCADE,
  CONSTRAINT `interviews_ibfk_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `positions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `department_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `status` enum('open','closed','on_hold') DEFAULT 'open',
  `job_description` text,
  `no_of_positions` int DEFAULT '1',
  `date_of_description` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `positions_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `rounds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rounds` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;


-- ============================ SEED DATA ============================
-- Application content (assessments, questions, badges) -- not user data.


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

LOCK TABLES `assessments` WRITE;
/*!40000 ALTER TABLE `assessments` DISABLE KEYS */;
INSERT INTO `assessments` (`id`, `title`, `description`, `category`, `difficulty`, `duration`, `passing_score`, `question_count`, `is_active`, `created_at`, `updated_at`) VALUES (1,'Logical Reasoning Test','Test your logical thinking and problem-solving abilities','aptitude','medium',30,70,20,1,'2025-11-03 16:06:51','2025-11-03 16:06:51'),(2,'JavaScript Fundamentals','Assess your knowledge of JavaScript basics','coding','easy',45,75,25,1,'2025-11-03 16:06:51','2025-11-03 16:06:51'),(3,'Data Structures & Algorithms','Advanced coding assessment on DSA concepts','coding','hard',60,80,30,1,'2025-11-03 16:06:51','2025-11-03 16:06:51'),(4,'SQL Database Queries','Test your SQL query writing and optimization skills','technical','medium',40,70,20,1,'2025-11-03 16:06:51','2025-11-03 16:06:51'),(5,'Communication Skills','Evaluate your professional communication abilities','behavioral','easy',25,65,15,1,'2025-11-03 16:06:51','2025-11-03 16:06:51');
/*!40000 ALTER TABLE `assessments` ENABLE KEYS */;
UNLOCK TABLES;

LOCK TABLES `assessment_questions` WRITE;
/*!40000 ALTER TABLE `assessment_questions` DISABLE KEYS */;
INSERT INTO `assessment_questions` (`id`, `assessment_id`, `question_text`, `option_a`, `option_b`, `option_c`, `option_d`, `correct_answer`, `explanation`, `difficulty`, `created_at`) VALUES (1,1,'If all Bloops are Razzies and all Razzies are Lazzies, then all Bloops are definitely Lazzies?','True','False','Cannot be determined','Insufficient data',0,'This is a syllogism. If A=B and B=C, then A=C','medium','2025-11-03 16:06:51'),(2,1,'What comes next in the series: 2, 6, 12, 20, 30, ?','40','42','44','46',1,'The differences are 4, 6, 8, 10, so next is +12 = 42','medium','2025-11-03 16:06:51'),(3,1,'If BOOK is coded as CPPL, how is WORD coded?','XPSE','VQQC','XNQC','WOSE',0,'Each letter is shifted by +1 in the alphabet','medium','2025-11-03 16:06:51');
/*!40000 ALTER TABLE `assessment_questions` ENABLE KEYS */;
UNLOCK TABLES;

LOCK TABLES `badges` WRITE;
/*!40000 ALTER TABLE `badges` DISABLE KEYS */;
INSERT INTO `badges` (`id`, `name`, `description`, `icon`, `criteria`, `created_at`) VALUES (1,'First Steps','Complete your first assessment','🎯','Complete 1 assessment','2025-11-03 16:06:51'),(2,'Quick Learner','Score above 80% in any assessment','⚡','Score 80%+ in any test','2025-11-03 16:06:51'),(3,'Perfect Score','Get 100% in an assessment','💯','Score 100% in any test','2025-11-03 16:06:51'),(4,'Assessment Master','Complete 10 assessments','🏆','Complete 10 assessments','2025-11-03 16:06:51'),(5,'Coding Ninja','Score above 90% in a coding assessment','👨‍💻','Score 90%+ in coding test','2025-11-03 16:06:51');
/*!40000 ALTER TABLE `badges` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;


-- Synthetic demo accounts. Passwords are bcrypt hashes of 'Password123!'.
INSERT INTO `companies`
  (`id`,`name`,`industry`,`registration_number`,`gstin`,`official_email`,`website`,
   `contact_number`,`company_size`,`address`,`password_hash`,`logo_file_name`,`logo_file_path`)
VALUES
  (1,'Acme Technologies','Information Technology','REG-ACME-0001','27AAAAA0000A1Z5',
   'hr@acme.example','https://acme.example','9000000001','51-200',
   '1 Example Street, Mumbai, MH 400001',
   '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',NULL,NULL);

INSERT INTO `candidates`
  (`id`,`position`,`first_name`,`last_name`,`email`,`phone`,`education`,
   `experience_years`,`skills`,`location`,`resume_file_name`,`resume_file_path`,
   `notes`,`password`,`company_id`)
VALUES
  (1,'Data Analyst','Asha','Rao','asha.rao@example.com','9000000101',
   'B.Tech Computer Science',2,'SQL, Python, Tableau','Mumbai',NULL,NULL,NULL,
   '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',1),
  (2,'Backend Engineer','Vikram','Nair','vikram.nair@example.com','9000000102',
   'B.E. Information Technology',4,'Python, FastAPI, PostgreSQL','Pune',NULL,NULL,NULL,
   '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',1);

INSERT INTO `interviews`
  (`id`,`company_id`,`candidate_id`,`candidate_name`,`position`,`round`,
   `interviewer_1`,`interview_date`,`interview_link`,`interview_location`,`notes`,`status`)
VALUES
  (1,1,1,'Asha Rao','Data Analyst','Technical Round','Priya Sharma',
   '2026-09-01 10:00:00','https://meet.example/abc-defg-hij',NULL,NULL,'scheduled'),
  (2,1,2,'Vikram Nair','Backend Engineer','HR Round','Rahul Menon',
   '2026-09-02 14:30:00',NULL,'Mumbai Office - Room 3',NULL,'completed');
