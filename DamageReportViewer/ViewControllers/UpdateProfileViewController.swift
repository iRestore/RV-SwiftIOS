//
//  UpdateProfileViewController.swift
//  CP Manager
//
//  Created by AnilKumar on 23/04/18.
//  Copyright © 2018 AnilKumar. All rights reserved.
//

import UIKit
import RSKImageCropper
import AWSS3
import AWSCore
import AWSCognito
//import SDWebImage

class UpdateProfileViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,RSKImageCropViewControllerDelegate {
    
    @IBOutlet weak var editPhotoBtn: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock? = nil

    @IBOutlet weak var updateProfileTableView: UITableView!
    var textFieldPlaceHolderArray : [String]!
    var textFieldDict : [String : String] = [String : String]()

    var imagePicker = UIImagePickerController()
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var userObj : [String : Any] =  [String : Any]()
    let prefs : UserDefaults = UserDefaults.standard
    var dataFromCellsDic = [String : String]()
    var oldDataDic = [String : String]()

    var cellDataArr = [String]()
    
    var croppedImageVal = UIImage()
    var alertMsg = String()
    var primaryPhone : String = ""
    let appDelegate: AppDelegate  = UIApplication.shared.delegate as! AppDelegate
    var submitButton :UIBarButtonItem!
    var isDataToSubmit = false
    var selectedIndexPath : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarSettings()
        // Do any additional setup after loading the view.
        
        self.updateProfileTableView.delegate = self
        self.updateProfileTableView.dataSource = self
        textFieldPlaceHolderArray = ["Email","Phone","First Name","Last Name","Job Title","Organization","City","County","State"]
        self.updateProfileTableView.tableFooterView = UIView()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UpdateProfileViewController.editButtonClicked(_:)))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        //greeshma
        
        
        let userId = UserDefaults.standard.value(forKey: "userId") as?  NSNumber
        if let  iconImage = UIImage.init(named: "cameraIcon") {
            profileImageView.image = iconImage
        }
        let imageName =  "\(userId!).png"
        
        if let image = getSavedImage(named: imageName) {
            // do something with image
            // editBtn.isHidden = false
            profileImageView.image = image.circleMasked
        }
        else
        {
            self.downloadProfileImage(imageName: imageName, isThumbNailImage: true)
            
        }
        
        
        
        
        
        let prefs = UserDefaults.standard
        
        let email  = prefs.value(forKey: Constants.EMAIL_KEY
            ) as! String
        cellDataArr.append(email)
        
        if  let PrimaryPhone = prefs.value(forKey: "primaryPhone") as? String {
            cellDataArr.append(PrimaryPhone)
            
        }
        else {
            cellDataArr.append("")
            
        }
        if  let firstName = prefs.value(forKey: "firstName") as? String {
            cellDataArr.append(firstName)
            
        }
        else {
            cellDataArr.append("")
            
        }
        if  let lastName = prefs.value(forKey: "lastName") as? String {
            cellDataArr.append(lastName)
            
        }
        else {
            cellDataArr.append("")
            
        }
        
        if  let job = prefs.value(forKey: "job") as? String {
            cellDataArr.append(job)
            
        }
        else {
            cellDataArr.append("")
            
        }
        
        if  let organization = prefs.value(forKey: "organization") as? String {
            cellDataArr.append(organization)
            
        }
        else {
            cellDataArr.append("")
            
        }
        if  let city = prefs.value(forKey: "city") as? String {
            cellDataArr.append(city)
            
        }
        else {
            cellDataArr.append("")
            
        }
        
        if  let county = prefs.value(forKey: "county") as? String {
            cellDataArr.append(county)
            
        }
        else {
            cellDataArr.append("")
            
        }
        if  let state = prefs.value(forKey: "state") as? String {
            cellDataArr.append(state)
            
        }
        else {
            cellDataArr.append("")
            
        }
        
        
        
        print(cellDataArr)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        activityIndicator.stopAnimating()
    }
    func navigationBarSettings() {
        
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationItem.hidesBackButton = false
        self.navigationController?.navigationBar.isTranslucent = true

        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 15.0) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationItem.title = NSLocalizedString("Update Profile", comment: "")
        
        var backButton: UIButton
        var leftBarBtnItem : UIBarButtonItem
        backButton = UIButton.init(type: UIButton.ButtonType.custom)
        backButton.setImage(UIImage.init(named: "back_green"), for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(UpdateProfileViewController.backButtonClicked), for: .touchUpInside)
        backButton.sizeToFit()
        leftBarBtnItem = UIBarButtonItem.init(customView: backButton)
        self.navigationItem.leftBarButtonItem = leftBarBtnItem
        
        submitButton = UIBarButtonItem(title: "Submit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(UpdateProfileViewController.submitBtnAction(sender:)))
        submitButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem  = submitButton
        submitButton.isEnabled = false
        
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            updateProfileTableView.contentInset = UIEdgeInsets.zero
        } else {
            updateProfileTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        updateProfileTableView.scrollIndicatorInsets = updateProfileTableView.contentInset
        if let _indexPath =   self.selectedIndexPath {
            updateProfileTableView.scrollToRow(at: _indexPath, at: .top, animated: true)

        }
        

    }
    
    @objc func backButtonClicked() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    

    
    
    //store updated profile data to server
    @objc func submitBtnAction(sender: UIBarButtonItem) {
        self.saveData()
        if Reachability.isConnectedToNetwork() == false {
            return
        }
        self.alertMsg = ""
        if ((dataFromCellsDic["firstName"])?.isEmpty)!  {
            
            self.alertMsg = "First Name"
        }
        if ((dataFromCellsDic["lastName"])?.isEmpty)!  {
            if self.alertMsg.isEmpty {
                self.alertMsg = "Last Name"
            }
            else {
                self.alertMsg = self.alertMsg + ", " + "Last Name"
            }

        }
        if ((dataFromCellsDic["job"])?.isEmpty)!  {
            if self.alertMsg.isEmpty {
                self.alertMsg = "Job Title"
            }
            else {
                self.alertMsg = self.alertMsg + ", " + "Job Title"
            }

            
        }
        if ((dataFromCellsDic["organization"])?.isEmpty)!  {
            if self.alertMsg.isEmpty {
                self.alertMsg = "Organization"
            }
            else {
                self.alertMsg = self.alertMsg + ", " + "Organization"
            }

        }
        if (self.alertMsg.isEmpty) == false {
            showAlertForProfile(title: " cannot be empty." )
            return
        }
        let isImageUploadedSuccessfully =  saveImage(image: croppedImageVal)
        if(isImageUploadedSuccessfully && isDataToSubmit ==  false) {
            
            let alert = UIAlertController(title: "Success", message: "Photo updated successfully" , preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style
                {
                case .default:
                    self.navigationController?.popToRootViewController(animated: true)
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                }}))
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.updateInfo()
    }
    func saveData(){
        
        for i in 0...textFieldPlaceHolderArray.count-1 {
            let placeHolderText = textFieldPlaceHolderArray[i]
            let textFieldString = self.textFieldDict[placeHolderText] as! String
           // let cellTextField =  self.textFieldDict[placeHolderText] as! UITextField
            switch (i){

            case 2 :
                dataFromCellsDic["firstName"] = textFieldString
                break
            case 3 :
                dataFromCellsDic["lastName"] = textFieldString
                break
            case 4 :
                dataFromCellsDic["job"] = textFieldString
                break
            case 5 :
                dataFromCellsDic["organization"] = textFieldString
                break
            case 6 :
                dataFromCellsDic["city"] = textFieldString
                break
            case 7 :
                dataFromCellsDic["county"] = textFieldString
                break
            case 8 :
                dataFromCellsDic["state"] = textFieldString
                break
            default:
                break
            }
            
        }
    }
    func saveUpdatedValues()
    {


        
    
        
        for i in 0...textFieldPlaceHolderArray.count-1 {
            let placeHolderText = textFieldPlaceHolderArray[i] as! String
            let cellTextFieldText =  self.textFieldDict[placeHolderText] as! String

            switch (i){
            case 2 :
                break
            case 3 :
                break
            case 4 :
                UserDefaults.standard.set(cellTextFieldText, forKey: "job")
                break
            case 5 :
                UserDefaults.standard.set(cellTextFieldText, forKey: "organization")
                break
            case 6 :
                UserDefaults.standard.set(cellTextFieldText, forKey: "city")
                break
            case 7 :
                UserDefaults.standard.set(cellTextFieldText, forKey: "county")
                break
            case 8 :
                UserDefaults.standard.set(cellTextFieldText, forKey: "state")
                break
            default:
                break
            }
            
        }
//        let encodedData = NSKeyedArchiver.archivedData(withRootObject: userObj)
//        prefs.set(encodedData, forKey: Constants.USER_DATA_OBJECT)
        self.prefs.synchronize()
    }
    func updateInfo()
    {

//        if  dataFromCellsDic["firstName"] != userObj["firstName"] as? String || dataFromCellsDic["lastName"] != userObj["lastName"] as? String || dataFromCellsDic["job"] != userObj["job"] as? String || dataFromCellsDic["organization"] != userObj["organization"] as? String || dataFromCellsDic["city"] != userObj["city"] as? String || dataFromCellsDic["state"] != userObj["state"] as? String || dataFromCellsDic["county"] != userObj["county"] as? String
//        {
            
            let postString = self.constructPostString()
            guard let postData1 = postString.data(using: String.Encoding.utf8) else { return }
        
            let apiClient  = V1ApiClient.init()
            apiClient.updateProfile(postData: postData1) {
                result in
                switch(result){
                case .Success(let response):
                        print("hi")
                    if let obj = response.data as? [String:Any] {
                    
                     
                        if obj["Error"] as! Bool {
                            let message =  obj["Message"] as! String
                            self.appDelegate.displayAlert(message: message, isActionRequired: true)
                        }
                        else
                        {
                            print(obj)
                            DispatchQueue.main.async()
                                {
                                    let alert = UIAlertController(title: "Success", message: obj["Message"] as? String, preferredStyle: UIAlertController.Style.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                        switch action.style
                                        {
                                        case .default:
                                                self.saveUpdatedValues()
                                            self.navigationController?.popToRootViewController(animated: true)

                                        case .cancel:
                                            print("cancel")

                                        case .destructive:
                                            print("destructive")

                                        }}))
                                    self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                case .Failure(let error):
                    print("hi")
                }
            }
            
            

        
    }
    func constructPostString () -> String {
        
        let prefs = UserDefaults.standard
        
        let phone  = prefs.value(forKey: Constants.PHONE_KEY) as! String
        let email  = prefs.value(forKey: Constants.EMAIL_KEY) as! String
        let emptySpaceString = ""
        var postString = "email=\(email)"
        postString =  postString.appending("&phone=\(phone)")
        
        if( primaryPhone != "") {
            postString =  postString.appending("&primaryPhone=\(primaryPhone)")
        }
        else{
            postString =  postString.appending("&primaryPhone=\(phone)")
            
        }
        
        if let firstName = dataFromCellsDic["firstName"] {
            postString = postString.appending("&firstName=\(firstName)")
        }
        if let lastName = dataFromCellsDic["lastName"] {
            postString = postString.appending("&lastName=\(lastName)")
        }
        if let organization = dataFromCellsDic["organization"] {
            postString = postString.appending("&organization=\(organization)")
        }
        if let job = dataFromCellsDic["job"] {
            postString = postString.appending("&job=\(job)")
        }
        if let city = dataFromCellsDic["city"] {
            if city == "" {
                postString = postString.appending("&city=' '")
                
            }
            else {
                postString = postString.appending("&city=\(city)")
            }
        }
        else {
            postString = postString.appending("&city=' '")

        }
        if let state = dataFromCellsDic["state"] {
            if state == "" {
                postString = postString.appending("&state=' '")

            }
            else {
                postString = postString.appending("&state=\(state)")

            }
        }
        else {
            postString = postString.appending("&state=' '")

        }
        if let county = dataFromCellsDic["county"] {
            if county == "" {
                postString = postString.appending("&county=' '")
                
            }
            else {
                postString = postString.appending("&county=\(county)")

            }
        }
        else{
            postString = postString.appending("&county=' '")

        }
        let owner  = prefs.object(forKey: Constants.accountKey) as! String
        let userType : String = prefs.object(forKey: Constants.DEFAULTS_USER_TYPE) as! String
        if(userType  == "EMPLOYEE") {
            postString = postString.appending("&owner=\(owner)")
        }
        else{
            postString = postString.appending("&owner= ")
        }
        postString = postString.appending("&userType=\(userType)")
        return postString
        //Constants.accountKey //[defaults valueForKey:DEFAULT_TENANT_ACCOUNT_KEY];
    }
    func showAlertForProfile(title :String)
    {
        DispatchQueue.main.async()
            {
                self.alertMsg = self.alertMsg + " " + title
                let alert = UIAlertController(title: "Attention Required!", message: self.alertMsg, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: .default, handler: { action in
                    switch action.style
                    {
                    case .default:
                        print("OK")
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                        
                    }}))
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.textFieldPlaceHolderArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! updateProfileTableViewCell
        cell.textField.placeholder = self.textFieldPlaceHolderArray[indexPath.row]
        if indexPath.row == 0  || indexPath.row == 1 || indexPath.row == 2  || indexPath.row == 3 {
            cell.textField.isUserInteractionEnabled = false
        }
        else {
            cell.textField.isUserInteractionEnabled = true

        }
        if let text = self.textFieldDict[cell.textField.placeholder!] {
            cell.textField.text = text
        }
        else {
            cell.textField.text = cellDataArr[indexPath.row]
            self.textFieldDict[cell.textField.placeholder!] = cell.textField.text

        }
        cell.textField.tag = indexPath.row
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50 //Choose your custom row height
    }

//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//            return 250
//    }
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 250))
//        footerView.backgroundColor = UIColor.clear
//        return footerView
//    }
    @IBAction func editButtonClicked(_ sender: Any)
    {
        let actionSheetControllerIOS8: UIAlertController = UIAlertController(title: "Please select", message: "Option to set picture", preferredStyle: .actionSheet)
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        
        let cameraActionButton = UIAlertAction(title: "Camera", style: .default)
        { _ in
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        actionSheetControllerIOS8.addAction(cameraActionButton)
        
        let galleryActionButton = UIAlertAction(title: "Gallery", style: .default)
        { _ in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                print("Button capture")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .savedPhotosAlbum;
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        actionSheetControllerIOS8.addAction(galleryActionButton)
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = actionSheetControllerIOS8.popoverPresentationController {
                popoverController.sourceView = profileImageView
                popoverController.sourceRect = profileImageView.bounds
                popoverController.permittedArrowDirections =  [.up]
            }
        }
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = UIImage ()
        if let _image : UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = _image
        }
        
        picker.dismiss(animated: false, completion: { () -> Void in
            
            var imageCropVC : RSKImageCropViewController!
            
            imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.circle)
            
            imageCropVC.delegate = self
            
            self.navigationController?.pushViewController(imageCropVC, animated: true)
            
        })
        
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        self.profileImageView.image = croppedImage.circleMasked
        croppedImageVal = croppedImage
        self.submitButton.isEnabled = true
        //        let success = saveImage(image: croppedImage)
        //        print(success)
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField)  {

            enableSubmitButton()
            let cell = textField.superview?.superview as? updateProfileTableViewCell
            if let _cell = cell {
                selectedIndexPath = updateProfileTableView.indexPath(for: _cell)!
                //let placeHolder = self.textFieldPlaceHolderArray[selectedIndexPath]
                //textFieldDict[placeHolder] = textField.text
            }

    }
    func textFieldDidEndEditing(_ textField: UITextField)  {
        let cell = textField.superview?.superview as? updateProfileTableViewCell
        if let _cell = cell {
            let placeHolder = self.textFieldPlaceHolderArray[(selectedIndexPath?.row)!]
            textFieldDict[placeHolder] = textField.text

        }
        selectedIndexPath  = nil
        enableSubmitButton()

    }
    func enableSubmitButton() {
        let firstNameText = (textFieldDict["First Name"])
        let lastNameText = (textFieldDict["Last Name"])
        let jobText = (textFieldDict["Job Title"])
        let organizationText = (textFieldDict["Organization"])
        let cityText = (textFieldDict["City"])
        let stateText = (textFieldDict["State"])
        let countyText = (textFieldDict["County"])
        
        
        if  ( (firstNameText != ""  && (firstNameText != (userObj["firstName"] as? String) )) ||
            (lastNameText != ""  && (lastNameText != userObj["lastName"] as? String) )  ||
            (jobText != ""  && (jobText != userObj["job"] as? String) )  ||
            (organizationText != ""  && (organizationText != userObj["organization"] as? String) )  ||
            (cityText != userObj["city"] as? String) ||
            (stateText != userObj["state"] as? String) ||
            (countyText != userObj["county"] as? String) )
            
        {
            isDataToSubmit = true
            submitButton.isEnabled = true
        }
        else {
            isDataToSubmit = false
            submitButton.isEnabled = false
            
        }
    }
    func saveImage(image: UIImage) -> Bool {
        
        let userId = UserDefaults.standard.value(forKey: "userId") as! Int
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        
        do {
            try data.write(to: directory.appendingPathComponent(String(format:"%d.png", userId))!)
            let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(String(format:"%d.png", userId))
            self.uploadProfileImagesToS3(imgPath: imagePAth) // gree
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func uploadProfileImagesToS3(imgPath: String) -> Void {
        
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.AWS_COGNITO_POOL_ID)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let fileURL = URL(fileURLWithPath: imgPath)
        var S3UploadKeyName = URL(fileURLWithPath: imgPath).lastPathComponent
        S3UploadKeyName = "\(S3UploadKeyName)"
        let S3BucketName = UserDefaults.standard.value(forKey: Constants.PROFILE_BUCKET_NAME) as! String
        let expression = AWSS3TransferUtilityUploadExpression()
        self.completionHandler = { (task, error) -> Void in
            DispatchQueue.main.sync(execute: {
                if ((error) != nil){

                }
                    
                else{


                }
                
            })
        }
        
        let  transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadFile( fileURL,
                                    bucket: S3BucketName as! String ,
                                    key: S3UploadKeyName,
                                    contentType: "image/png",
                                    expression: expression,
                                    completionHandler: self.completionHandler).continueWith { (task) -> AnyObject? in
                                        if let error = task.error {
                                            print("Error: \(error.localizedDescription)")
                                        }
                                        
                                        if let _ = task.result {
                                            
                                        }
                                        
                                        return nil
        }
    }
 
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }

    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    func downloadProfileImage(imageName: String, isThumbNailImage:Bool) -> Void {
        
        var dnldCompletionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.AWS_COGNITO_POOL_ID)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        var S3BucketNamethumb = UserDefaults.standard.value(forKey: Constants.PROFILE_BUCKET_NAME) as! String
        if(isThumbNailImage){
            S3BucketNamethumb = "\(S3BucketNamethumb)-thumbnails"
        }
        
        
        let S3DownloadKeyName : String = imageName
        let expression = AWSS3TransferUtilityDownloadExpression()
        //        expression.setValue("public-read", forRequestParameter: "x-amz-acl")
        
        dnldCompletionHandler = { (task, location, data, error) -> Void in
            DispatchQueue.main.sync(execute: {
                if ((error) != nil){
                    print("Failed with error")
                    print("Error: \(error!)")
                }
                else{
                    //Set your image
                    let downloadedImage = UIImage(data: data!)
                    self.profileImageView.image = downloadedImage?.circleMasked
                    
                    guard let data = downloadedImage!.jpegData(compressionQuality: 1) ?? downloadedImage!.pngData() else {
                        return
                    }
                    guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
                        return
                    }
                    do {
                        
                        try data.write(to: directory.appendingPathComponent(imageName)!
                        )
                        return
                        
                    } catch {
                        print(error.localizedDescription)
                        return
                    }
                    
                    
                    // Define identifier
                    let notificationName = Notification.Name("NotificationImageDownload")
                    
                    NotificationCenter.default.post(name: notificationName, object: nil)
                    
                }
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.downloadData(fromBucket: S3BucketNamethumb, key: S3DownloadKeyName, expression: expression, completionHandler: dnldCompletionHandler).continueWith { (task) -> AnyObject? in
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
            }
            if let _ = task.result {
                print("Download Starting!")
            }
            return nil
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
class updateProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
}
