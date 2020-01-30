//
//  Constants.swift
//  QA Manager
//
//  Created by Greeshma Mullakkara on 25/01/18.
//  Copyright © 2018 iRestoreApp. All rights reserved.
//

import Foundation



struct  Constants
{
    
    static let FILTER_DISPLAY_DICT = "displayDict"
    static let FILTER_VALUE_DICT = "valueDict"

    
    static let FILTER_TABLECELL_NORML_HEIGHT  = 50
    static let EXTENDING_CELL_HEIGHT   = -1
    static let FILTER_ISACTIVE = "isActive"
    static let dateFormatterKey =  "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static let listScreenDateFormat = "MM-dd-yyyy HH:mm:ss"
    static let fromDateDisplayFormat = "MM-dd-yyyy"
    static let fromDateValueFormat = "yyyy-mm-dd"

//    static let dateDisplayFormatKey = "MM/dd/YYYY"
//    static let timeDisplayFormatKey = "HH:mm"
//    static let simpleDateFormatterKey =  "MM/dd/YYYY HH:mm a"//   "yyyy-MM-dd HH:mm:ss"



    static let pushNotificationKey = "pushNotification"
    static let FIREBASE_EMAIL = "mobility.bizradr@gmail.com"
    static let FIREBASE_PWD = "bizradr2017"
    
    

    static let AWS_COGNITO_POOL_ID = "us-east-1:119fd168-263e-41e6-8fff-a966cf0f9b33"
    
    
    static let IS_OTP_REQUIRED             = "otpRequired"
    static let IS_SUBSCRIPTION_EXISTS    =  "subscriptionExists"
    static let IS_USER_APPROVED            = "user_approved"
    static let IS_TERMS_EXISTS             = "termsDataExists"
    static let IS_SIGN_COMPLETED           = "signupCompleted"
    
    static let  USER_STATUS_SUBMITEED = "submitted"
    static let  USER_STATUS_APPROVED  = "approved"
    static let  USER_STATUS_REJECTED  = "rejected"
    static let  USER_STATUS_REVOKED  = "revoked"
    
    //URLs and Paramters
    static let GET_REPORTS_V2_URL = "/api/damagereports/filters"
    static let SUBMITTEDBY_V2_URL = "/api/users/getUserSubscriptionDetailsByApplication"
    static let ADDRESS_V2_URL = "/api/damagereports/addressSearch"
     static let TAGS_V2_URL = "/api/damagereports/tags"
    static let FEEDERLINE_V2_URL = "/api/damagereports/feederLine"

    //URLs and Paramters
    static let SERVER_ADRESS = "https://_SERVER_.irestore.info" //->dev //dabeta
    static let LOCATION_REGION = "/v1/tenants/get/locations/1/"
    static let SIGNUP = "/v1/signup/checkUser?"
    static let GET_OTP_API = "/v1/common/otp?"
    static let CREATE_PROFILE_API = "/v1/common/users"
    static let UPDATE_PROFILE_API = "/v1/common/users/profile"
    static let ADMIN_APPROVAL_API = "/v1/common/subscriptions/?"
    static let TERMS_CONDITIONS_API = "/v1/common/subscriptions/deviceConfiguration/"
    static let IMAGE_UPLOADED_ACKNOWLEDGE  = "/v1/vda/:deviceReportId/images"
    static let SYNC_API = "/v1/common/sync/:application/?os=IOS&email=:email&phone=:phone"
    static let CONFIGURATION = "/v1/common/users/:userId/:application/configuration"
    static let SUBSCRIPTION = "/v1/common/users/:userId/subscription/:phone/:application"
    static let CREATE_PROFILE = "/v1/common/users"
    static let RESEND_OTP = "/v1/common/otp/?phone=:phone"
    static let GET_USERSBY_ROLE = "/v1/common/users/role/:roleName"
    static let GET_CONTRACTORS = "/v1/common/agencies/QAM"
    static let FILTER_API = "/v1/qaManager/:userId/?" ///v1/jobs?"
    static let GET_ALL_LOCATIONS = "/v1/common/utilities/:utilityId/locations?"
    static let SET_NOTIFICATION = "/v1/common/users/notificationRules"

    //PORT
    static let SERVER_LOADBALANCER_ADRESS = "https://__SERVER1__/api/qam/" //->dev //dabeta
    static let GET_ALL_INSPECTIONTYPES = "inspection/inspectiontypes"
    static let GET_ALL_QUESTIONTYPES = "question/questiontypes"
    static let GET_ALL_QUESTIONSFORROLE = "filterQuestions?"
    static let GET_ALL_TARGETEDTEMPLATES = "targetedInspectionTemplates/"
    static let GET_ALL_TARGETEDQUESTIONSFORTEMPLATE = "targetedInspectionTemplate/"
    static let UPDATE_INSPECTIONCOUNT = "targetedInspectionTemplate/inspectionConducted/"


    
    static let serverParamKEY = "_SERVER_"
    static let serverParam1KEY = "__SERVER1__"
    static let userIDParamValue = ":userId"
    static let phoneParamValue = ":phone"
    static let roleValue = ":roleName"

    static let applicationParamValue = ":application"
    static let emailParamValue = ":email"
    static let utilityIdParamValue = ":utilityId"

    
    
    static let MASTER_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJpUmVzdG9yZSIsImF1ZCI6ImdlbmVyYWwiLCJzdWIiOiJhdXRoZW50aWNhdGlvbiIsImlhdCI6MTQ2OTA4NzYwMX0.48fKAGieV0j9kQDu9wlaLi6a1B837nuCqthJmROSy-0"
    
    static let MASTER_ACCOUNT_KEY  = "general"
    static let accessToken = "x-access-token"
    static let accountKey = "x-account-key"
    static let applicationKey = "DRV"
    static let DEFAULT_TENANT_NAME = "tenantName"
    static let IS_OTP_DONE = "isOTPDone"
    static let IS_CREATEPROFILE_DONE = "isCreateProfileDone"
    static let IS_ADMIN_APPROVAL_DONE = "isAdminApprovalDone"
    static let IS_TERMS_CONDITIONS_DONE = "isTermsDone"
    static let IS_Contracter = "isContracter"
    static let IS_OTP_SCREEN_REQUIRED = "isOTPSCreenRequired"
    static let OTP_VALUE = "otpValue"
    static let OTP_TIMER_VALUE = "otpTimerValue"
    static let IS_CREATE_PROFILE_SCREEN_REQUIRED = "isCreateProfileReqired"
    static let USER_DATA_OBJECT = "userData"
    static let TENANT_DATA_OBJECT = "tenantData"
    static let CONFIGURATION_OBJECT = "configuration"
    static let CITY = "city"
    static let STATE = "state"
    static let COUNTY = "county"
    static let USER_ID = "userID"
    static let USER_STATUS = "userStatus"
    static let UTILITY_NAME = "utilityName" // For storing the name of utility (either contractor or Employee)
    static let UTILITY_ID = "utilityId" // For storing the name of utility (either contractor or Employee)

    static let DEFAULTS_USER_TYPE = "userType"
    static let BUCKET_NAME = "s3Bucket"
   static let  DEFAULTS_TENANT_CONFIG = "tenantConfig"

    static let PROFILE_BUCKET_NAME = "profilePicBucket"
    static let FIREBAE_DB = "firebaseDb"
    static let PHONE_KEY = "phone"
    static let EMAIL_KEY = "emailId"

    
    
    //Drv specific key
    static let  PERMISSION_TO_VIEW_REPORT = "viewReportPermission"
    static let  PERMISSION_TO_VIEW_ACKNOWLEDGE = "viewAcknowledgedReportPermission"



    
    //Message Texts
    static let USER_REJECTED_ALERT_TEXT  = "Your request for Damage Report Viewer Subscription has been declined. Please contact the Utility Admin for detail"
    
    static let USER_REVOKED_ALERT_TEXT  = "Your subscription to Damage Report Viewer has been revoked.  Please contact the Utility Admin for details"
    
    static let USER_DEVICE_STRING_MISMATCH_TEXT = "Damage Report Viewer subscription with the same phone number is active on another device."
    
    static let USER_SUBMITTED_TEXT  = "Your request for Damage Report Viewer Subscription is waiting for Admin Approval"
    
    static let FETCH_CONFIGURATION_TEXT  = "Error in setting up the configuration."
    
            static let USER_SUBSCRIPTION_DOESNOT_EXISTS_ALERT_TEXT  = "Your subscription to Inspection has been removed. Please contact the Utility Admin for detail"


}
