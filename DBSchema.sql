/*
MySQL - 5.5.50-log : Database - socioforms
*********************************************************************
*/


/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`socioforms` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `socioforms`;

/*Table structure for table `tblusers` */
DROP TABLE IF EXISTS `tblusers`;
CREATE TABLE `tblusers` (
  `userID` int(11) NOT NULL AUTO_INCREMENT,
  `userName` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `tblusers` */
insert  into `tblusers`(`userID`,`userName`,`email`) values (1,'Deepak Arora','divinedeepak92@gmail.com'),(2,'Test','test@gmail.com');


/*Table structure for table `tblforms` */
DROP TABLE IF EXISTS `tblforms`;
CREATE TABLE `tblforms` (
  `formID` int(11) NOT NULL AUTO_INCREMENT,
  `userID` int(11) DEFAULT NULL,
  `formName` varchar(200) DEFAULT 'null',
  `formDesc` text,
  `formCreationDate` datetime DEFAULT NULL,
  `lastUpdatedOn` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`formID`),
  KEY `IX_tblforms_userID` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `tblforms` */
insert  into `tblforms`(`formID`,`userID`,`formName`,`formDesc`,`formCreationDate`) values (1,1,'Sample Form','Please fill in the Details',now()),(2,1,'Sample Form 2','Please fill in the Details',now());


/*Table structure for table `tblquestiontype` */
DROP TABLE IF EXISTS `tblquestiontype`;
CREATE TABLE `tblquestiontype` (
  `typeID` tinyint(4) NOT NULL AUTO_INCREMENT,
  `typeDesc` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`typeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `tblquestiontype` */
insert  into `tblquestiontype`(`typeID`,`typeDesc`) values (1,'Input'),(2,'Textarea'),(3,'Radio'),(4,'CheckBox'),(5,'DropDown'),(6,'File');


/*Table structure for table `tblquestions` */
DROP TABLE IF EXISTS `tblquestions`;
CREATE TABLE `tblquestions` (
  `quesID` int(11) NOT NULL AUTO_INCREMENT,
  `formID` int(11) DEFAULT NULL,
  `quesType` tinyint(4) DEFAULT NULL,
  `quesDesc` text,
  `IsRequired` bit(1) DEFAULT b'0',
  `createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`quesID`),
  KEY `FK_tblQuestions_formID` (`formID`),
  CONSTRAINT `FK_tblQuestions_formID` FOREIGN KEY (`formID`) REFERENCES `tblforms` (`formID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


/*Table structure for table `tbloptions` */
DROP TABLE IF EXISTS `tbloptions`;
CREATE TABLE `tbloptions` (
  `optionID` int(11) NOT NULL AUTO_INCREMENT,
  `quesID` int(11) DEFAULT NULL,
  `optionDesc` varchar(500) DEFAULT NULL,
  `submitCount` int(11) DEFAULT '0',
  PRIMARY KEY (`optionID`),
  KEY `FK_tblOptions_quesID` (`quesID`),
  CONSTRAINT `FK_tblOptions_quesID` FOREIGN KEY (`quesID`) REFERENCES `tblquestions` (`quesID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


/*Table structure for table `tblsubmissions` */
DROP TABLE IF EXISTS `tblsubmissions`;
CREATE TABLE `tblsubmissions` (
  `answerID` int(11) NOT NULL AUTO_INCREMENT,
  `quesID` int(11) NOT NULL,
  `answerText` text,
  PRIMARY KEY (`answerID`),
  KEY `FK_tblSubmissions_quesID` (`quesID`),
  CONSTRAINT `FK_tblSubmissions_quesID` FOREIGN KEY (`quesID`) REFERENCES `tblquestions` (`quesID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



/* Procedure structure for procedure `getAllSubmissions` */

/*!50003 DROP PROCEDURE IF EXISTS  `getAllSubmissions` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `getAllSubmissions`(p_formID INT)
    READS SQL DATA
BEGIN
	SET @@group_concat_max_len = 10240;
	SELECT  f.formName, f.formDesc,q.quesDesc,typeDesc,
	GROUP_CONCAT(COALESCE(answerText,'Not Answered') SEPARATOR '^') AS 'answers'
	FROM tblforms f 
	INNER JOIN tblquestions q ON q.formID = f.formID AND f.formID=1
	INNER JOIN tblquestiontype qt ON qt.typeID = q.QuesType
	LEFT JOIN tblsubmissions s ON s.quesID = q.quesID 
	LEFT JOIN tbloptions o ON o.quesID = q.quesID AND IF(o.quesID = q.quesID, answerText = o.optionDesc,TRUE)
	GROUP BY q.quesID;
END */$$
DELIMITER ;

/* Procedure structure for procedure `getFormData` */

/*!50003 DROP PROCEDURE IF EXISTS  `getFormData` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `getFormData`(p_formID int)
    READS SQL DATA
BEGIN
	SELECT formname 'form Title',formDesc 'form Details',quesDesc 'Questions',typeDesc 'Question Type',GROUP_CONCAT(optionDesc) AS 'options'
	FROM tblforms f 
	INNER JOIN tblquestions q  ON q.formID = f.formID AND  f.formID = p_formID
	INNER JOIN tblquestionType qt ON qt.`typeID` = q.`quesType`
	LEFT JOIN tbloptions o ON o.quesID = q.quesID
	GROUP BY q.quesID
	ORDER BY q.quesID ASC;
    END */$$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
