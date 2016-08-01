
######################################################### CREATE ###########################################################

/*Creating a form */

INSERT  INTO `tblforms`(`userID`,`formName`,`formDesc`,`formCreationDate`) VALUES (1,'Sample Form new','Please fill in the Details',NOW());
SELECT LAST_INSERT_ID() INTO @formID FROM tblforms LIMIT 1;
INSERT  INTO `tblquestions`(`formID`,`quesType`,`quesDesc`,`IsRequired`) VALUES 
(@formID,1,'Name',0),(@formID,1,'Email ID',0),(@formID,1,'Phone No',0);
UPDATE tblforms SET lastUpdatedOn = NOW() WHERE formID = 1;


######################################################### READ ###########################################################

## Get all forms created by a user with LAST UPDATED FORM ON TOP
SELECT username,f.formID,formname,formDesc
FROM tblusers u 
	INNER JOIN tblForms f ON u.userID = f.userID  AND u.userID = 1
ORDER BY f.lastupdatedon DESC;

## User can choose to view and edit any form and that forms data should get loaded by calling following sp
CALL getFormData(form_id_to_be_passed); -- parameter=formID


######################################################## UPDATE ########################################################

## if the user wants to edit form Title or Desc
UPDATE tblforms 
SET formname ='Sample Form',
    formDesc = 'Please fill in the Details'
WHERE formID = 1;

## IF the user wants to add questions in a form, 
## we need form ID, question type,question Text and whether its a mandatory question or not.
## in case of an MCQ all the options associated with that question will be saved in tblOptions.

INSERT INTO tblquestions (formID,quesType,quesDesc,IsRequired) VALUES (3,2,'Address',0);
UPDATE tblforms SET lastUpdatedOn = NOW() WHERE formID = 3;


######################################################### DELETE ###########################################################

## Remove a question from a form
## deleting the question from question table will also delete its corresponding options and submissions(if any).
DELETE FROM tblquestions WHERE quesID = 4;

##Delete the entire form
DELETE FROM tblforms WHERE formID = 3;


######################################################### SHARING ###########################################################
## if the admin wants to share the form
## he can click the share button which will give the url of the project like 'www.socioforms.com/get' followed by the form ID
## ie. 'www.socioforms.com/get/1'.
## url mapper will send this formID to respective view(controller) and that view can query the model for the formId given.

CALL getFormData(form_id_to_be_passed);

######################################################### SUBMISSIONS ########################################################### 

##creating entries for submissions
INSERT INTO tblsubmissions (quesID,answerText) VALUES(1,'test1'),(2,'Test1@gmail.com'),(3,'8888555501');
INSERT INTO tblsubmissions (quesID,answerText) VALUES(4,'Bangalore');
## To view all the submitted answer 
## Since mySql doesnt allow Pivoting Table we can't see all submitted data in tabular forms with questions as table headers.
## The best we can do would be like...
CALL getAllSubmissions (form_id_to_be_passed) ;

## the above SP will give us all the answer concatnated by a special symbol which we can separate at application level.
## BUT ITS ALSO NOT A VERY CLEAN SOLUTION.

######################################################### SPECIAL CASES ###########################################################
## if user wants to see any particular form like SELECT all forms which have an input field containing email regex, etc.
## we can either see whether the question text contains the word email or not..or the answer submitted contains something that looks like an email.
SELECT f.formID,formName FROM tblforms f
INNER JOIN tblquestions q ON q.formID = f.formID
INNER JOIN tblsubmissions s ON s.quesID =q.quesID
WHERE answertext REGEXP '^.*@.*[\.].*$' -- or q.quesDesc like '%email%'
GROUP BY f.formID;


