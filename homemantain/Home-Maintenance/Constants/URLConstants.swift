//
//  URLConstants.swift
//  Home-Maintenance
//
//  Created by Bani on 11/01/2018.
//  Copyright © 2018 Ultron mobile. All rights reserved.
//

import Foundation
class URLConstants: NSObject{
	private struct Domains {
		//static let Dev = "http://54.64.155.65:801"
        static let Dev = "http://172.16.1.30"
        static let DevPort = ":801"
        //static let DevPort = ":803"
        //static let Dev = "http://172.16.1.71"
		static let UAT = ""
	}
	
	private  struct Routes {
		static let Api = "/Api"
	}
	
	//public static let DefaultIP = "54.64.155.65:801"
    public static let DefaultPrefix = "http://"
    public static let DefaultIP = "172.16.1.30"
    public static let DefaultPORT = ":801"
    //public static let DefaultPORT = ":803"
    //public static let DefaultIP = "172.16.1.71"
    public static let ImagePrefixURLBase = "http://172.16.1.30"
    public static let ImagePort = ":802"
    
	private  static let Domain = Domains.Dev + Domains.DevPort
	private  static let Route = Routes.Api
	private  static let BaseURL = Domain + Route
    static var ImagePrefixURL: String {
        if UserDefaults.standard.value(forKey: "IP") != nil {
            return DefaultPrefix + UserDefaults.standard.string(forKey: "IP")! + ImagePort + "/"
        } else {
           return ImagePrefixURLBase + ImagePort
        }
        
    }
	static var DownloadDB: String {
        if UserDefaults.standard.value(forKey: "IP") != nil {
            return DefaultPrefix + UserDefaults.standard.string(forKey: "IP")! + DefaultPORT + Routes.Api + "/Download"
        } else {
            return BaseURL + "/Download"
        }
	}
	
	static var DownloadDBSub: String {
        if UserDefaults.standard.value(forKey: "IP") != nil {
            return DefaultPrefix + UserDefaults.standard.string(forKey: "IP")! + DefaultPORT + Routes.Api + "/Download2"
        } else {
            return BaseURL  + "/Download2"
        }
	}
    static var UploadSqlite: String {
        if UserDefaults.standard.value(forKey: "IP") != nil {
            return DefaultPrefix + UserDefaults.standard.string(forKey: "IP")! + DefaultPORT + Routes.Api + "/Sqlite"
        } else {
            return BaseURL  + "/Sqlite"
        }
    }
    static var UploadPic: String {
        if UserDefaults.standard.value(forKey: "IP") != nil {
            return DefaultPrefix + UserDefaults.standard.string(forKey: "IP")! + DefaultPORT + Routes.Api + "/Picture/"
             //return BaseURL + "/Picture/"
        } else {
            return BaseURL + "/Picture/"
        }
    }

}
