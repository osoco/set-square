/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activation`
--

DROP TABLE IF EXISTS `activation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activation` (
  `Name` varchar(20) NOT NULL DEFAULT '',
  `Id` varchar(50) NOT NULL DEFAULT '',
  `Activated` char(1) NOT NULL DEFAULT 'N',
  `IP` varchar(15) DEFAULT NULL,
  `Email` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bookexportimport`
--

DROP TABLE IF EXISTS `bookexportimport`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bookexportimport` (
  `ID` int(3) NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) NOT NULL DEFAULT '',
  `Method` char(2) NOT NULL DEFAULT '',
  `Time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IP` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bookmarkhits`
--

DROP TABLE IF EXISTS `bookmarkhits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bookmarkhits` (
  `BookmarkID` int(3) NOT NULL DEFAULT '0',
  `Name` varchar(20) NOT NULL DEFAULT '',
  `Time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IP` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`BookmarkID`,`Name`,`Time`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `captchahits`
--

DROP TABLE IF EXISTS `captchahits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `captchahits` (
  `ID` int(3) NOT NULL AUTO_INCREMENT,
  `Code` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Entered` varchar(50) COLLATE latin1_general_ci NOT NULL,
  `Username` varchar(20) COLLATE latin1_general_ci NOT NULL,
  `Email` varchar(100) COLLATE latin1_general_ci NOT NULL,
  `IP` varchar(15) COLLATE latin1_general_ci NOT NULL,
  `Source` varchar(20) COLLATE latin1_general_ci NOT NULL,
  `Time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci COMMENT='Catch Captcha failures';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comments` (
  `ID` int(3) NOT NULL AUTO_INCREMENT,
  `BID` int(3) NOT NULL,
  `Title` varchar(100) COLLATE latin1_general_ci NOT NULL,
  `Comment` text COLLATE latin1_general_ci NOT NULL,
  `Author` varchar(20) COLLATE latin1_general_ci NOT NULL,
  `Date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ParentID` int(3) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `configs`
--

DROP TABLE IF EXISTS `configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `configs` (
  `config_name` varchar(100) NOT NULL,
  `config_value` varchar(255) NOT NULL,
  `config_description` text NOT NULL,
  `config_type` varchar(30) NOT NULL,
  `config_group` int(3) NOT NULL,
  `config_choices` text NOT NULL,
  PRIMARY KEY (`config_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='Configuration variables';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `configs_groups`
--

DROP TABLE IF EXISTS `configs_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `configs_groups` (
  `ID` int(3) NOT NULL,
  `title` varchar(30) NOT NULL,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='Groups of configuration values';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ebhints`
--

DROP TABLE IF EXISTS `ebhints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ebhints` (
  `ID` int(3) NOT NULL AUTO_INCREMENT,
  `Popup` char(1) NOT NULL DEFAULT '0',
  `Name` varchar(20) NOT NULL DEFAULT '',
  `Time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IP` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `favourites`
--

DROP TABLE IF EXISTS `favourites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `favourites` (
  `ID` int(3) NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) NOT NULL DEFAULT '',
  `Title` varchar(100) NOT NULL DEFAULT '',
  `FolderID` int(3) NOT NULL,
  `Url` text NOT NULL,
  `Description` varchar(150) DEFAULT '',
  `ADD_DATE` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `LAST_VISIT` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `LAST_MODIFIED` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `folders`
--

DROP TABLE IF EXISTS `folders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folders` (
  `ID` int(3) NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) NOT NULL DEFAULT '',
  `Title` varchar(30) NOT NULL DEFAULT '',
  `Description` varchar(150) DEFAULT '',
  `PID` int(3) NOT NULL DEFAULT '0',
  `ADD_DATE` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gfolders`
--

DROP TABLE IF EXISTS `gfolders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gfolders` (
  `ID` int(3) NOT NULL AUTO_INCREMENT,
  `Group_ID` int(3) NOT NULL DEFAULT '0',
  `FolderID` int(3) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups` (
  `Group_ID` int(3) NOT NULL AUTO_INCREMENT,
  `Group_Name` varchar(20) NOT NULL DEFAULT '',
  `Manager` varchar(20) NOT NULL DEFAULT '',
  `Description` varchar(100) NOT NULL DEFAULT '',
  `Password` varchar(50) DEFAULT NULL,
  `Date_Created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`Group_ID`),
  UNIQUE KEY `Group_Name` (`Group_Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gsubscriptions`
--

DROP TABLE IF EXISTS `gsubscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gsubscriptions` (
  `ID` int(3) NOT NULL AUTO_INCREMENT,
  `Group_ID` int(3) NOT NULL DEFAULT '0',
  `Name` varchar(20) NOT NULL DEFAULT '',
  `Date_Join` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Priv` char(1) NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `loginhits`
--

DROP TABLE IF EXISTS `loginhits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `loginhits` (
  `ID` int(5) NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) NOT NULL DEFAULT '',
  `Time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IP` varchar(15) NOT NULL DEFAULT '',
  `Success` char(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `news`
--

DROP TABLE IF EXISTS `news`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `news` (
  `NewsID` int(3) NOT NULL AUTO_INCREMENT,
  `Author` varchar(20) NOT NULL DEFAULT '',
  `Title` varchar(75) NOT NULL DEFAULT '',
  `Msg` longtext NOT NULL,
  `Date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`NewsID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `newshits`
--

DROP TABLE IF EXISTS `newshits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `newshits` (
  `ID` int(3) NOT NULL AUTO_INCREMENT,
  `NewsID` int(3) NOT NULL DEFAULT '0',
  `Source` char(1) NOT NULL DEFAULT '',
  `Time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IP` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `searches`
--

DROP TABLE IF EXISTS `searches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `searches` (
  `ID` int(4) NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) NOT NULL DEFAULT '',
  `Keyword` varchar(50) NOT NULL DEFAULT '',
  `Time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IP` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session` (
  `Name` varchar(20) NOT NULL DEFAULT '',
  `Pass` varchar(50) NOT NULL DEFAULT '',
  `Email` varchar(100) NOT NULL DEFAULT '',
  `PassHint` varchar(150) NOT NULL DEFAULT '',
  `LastLog` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `DateJoin` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Status` varchar(20) NOT NULL DEFAULT '',
  `Style` varchar(20) NOT NULL DEFAULT 'Auto',
  `LastActivity` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`Name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `ID` int(4) NOT NULL AUTO_INCREMENT,
  `Title` varchar(50) NOT NULL,
  `Date_Added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags_added`
--

DROP TABLE IF EXISTS `tags_added`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags_added` (
  `B_ID` int(4) NOT NULL DEFAULT '0',
  `Date_Added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`B_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tags_books`
--

DROP TABLE IF EXISTS `tags_books`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags_books` (
  `B_ID` int(4) NOT NULL DEFAULT '0',
  `T_ID` int(4) NOT NULL DEFAULT '0',
  `Date_Added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`B_ID`,`T_ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

