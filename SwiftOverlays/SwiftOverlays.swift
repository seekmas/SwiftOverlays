//
//  SwiftOverlays.swift
//  SwiftTest
//
//  Created by Peter Prokop on 15/10/14.
//  Copyright (c) 2014 Peter Prokop. All rights reserved.
//

import Foundation
import UIKit

class SwiftOverlays: NSObject
{
    // Workaround for "Class variables not yet supported"
    // You can customize these values
    struct Statics {
        // Some random number
        static let containerViewTag = 456987123
        
        static let cornerRadius = CGFloat(10)
        static let padding = CGFloat(10)
        
        static let backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        static let textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        static let font = UIFont(name: "HelveticaNeue", size: 14)
        
        // Annoying notifications on top of status bar
        static let bannerDissapearAnimationDuration = 0.5
    }
    
    private struct PrivateStaticVars {
        static var bannerWindow : UIWindow?
    }
    
    class func showCenteredWaitOverlay(parentView: UIView) -> UIView {
        let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        ai.startAnimating()
        
        let containerViewRect = CGRectMake(0,
            0,
            ai.frame.size.width * 2,
            ai.frame.size.height * 2)
        
        let containerView = UIView(frame: containerViewRect)
        
        containerView.tag = Statics.containerViewTag
        containerView.layer.cornerRadius = Statics.cornerRadius
        containerView.backgroundColor = Statics.backgroundColor
        containerView.center = CGPointMake(parentView.bounds.size.width/2,
            parentView.bounds.size.height/2);
        
        ai.center = CGPointMake(containerView.bounds.size.width/2,
            containerView.bounds.size.height/2);
        
        containerView.addSubview(ai)
        
        parentView.addSubview(containerView)
        
        return containerView
    }
    
    class func showCenteredWaitOverlayWithText(parentView: UIView, text: NSString) -> UIView  {
        let constraintSize = CGSizeMake(parentView.bounds.size.width * 0.9, parentView.bounds.size.height * 0.9);
        let textSize = text.sizeWithAttributes([NSFontAttributeName: Statics.font])

        let ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        ai.startAnimating()
        
        let actualSize = CGSizeMake(ai.frame.size.width + textSize.width + Statics.padding * 3,
            max(textSize.height, ai.frame.size.height) + Statics.padding * 2)
        
        // Container view
        let containerViewRect = CGRectMake(0,
            0,
            actualSize.width,
            actualSize.height)
        
        let containerView = UIView(frame: containerViewRect)
        
        containerView.tag = Statics.containerViewTag
        containerView.layer.cornerRadius = Statics.cornerRadius
        containerView.backgroundColor = Statics.backgroundColor
        containerView.center = CGPointMake(parentView.bounds.size.width/2,
            parentView.bounds.size.height/2);
        
        var frame = ai.frame
        frame.origin.x = Statics.padding
        frame.origin.y = (actualSize.height - frame.size.height)/2
        ai.frame = frame
        
        containerView.addSubview(ai)
        
        // Label
        let labelRect = CGRectMake(ai.frame.size.width + Statics.padding * 2,
            Statics.padding,
            textSize.width,
            textSize.height)
        let label = UILabel(frame: labelRect)
        label.font = Statics.font
        label.textColor = Statics.textColor
        label.text = text
        label.numberOfLines = 0
        containerView.addSubview(label)
        
        parentView.addSubview(containerView)
        
        return containerView
    }
    
    class func removeAllOverlaysFromView(parentView: UIView) {
        var overlay: UIView?

        while true {
            overlay = parentView.viewWithTag(Statics.containerViewTag)
            if overlay == nil {
                break
            }
            
            overlay!.removeFromSuperview()
        }
    }
    
    class func showAnnoyingNotificationOnTopOfStatusBar(notificationView: UIView, duration: NSTimeInterval) {
        if PrivateStaticVars.bannerWindow == nil {
            PrivateStaticVars.bannerWindow = UIWindow()
            PrivateStaticVars.bannerWindow!.windowLevel = UIWindowLevelStatusBar + 1
        }
        
        PrivateStaticVars.bannerWindow!.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, notificationView.frame.size.height)
        PrivateStaticVars.bannerWindow!.hidden = false
        
        let selector = Selector("closeAnnoyingNotificationOnTopOfStatusBar:")
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: selector)
        notificationView.addGestureRecognizer(gestureRecognizer)
        
        PrivateStaticVars.bannerWindow!.addSubview(notificationView)
        self.performSelector(selector, withObject: notificationView, afterDelay: duration)
    }
    
    class func closeAnnoyingNotificationOnTopOfStatusBar(sender: AnyObject) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
    
        var notificationView: UIView?
        
        if sender.isKindOfClass(UITapGestureRecognizer) {
            notificationView = (sender as UITapGestureRecognizer).view!
        } else if sender.isKindOfClass(UIView) {
            notificationView = (sender as UIView)
        }
        
        UIView.animateWithDuration(Statics.bannerDissapearAnimationDuration,
            animations: { () -> Void in
                let frame = notificationView!.frame
                notificationView!.frame = frame.rectByOffsetting(dx: 0, dy: -frame.size.height)
            },
            completion: { (finished) -> Void in
                notificationView!.removeFromSuperview()
                
                PrivateStaticVars.bannerWindow!.hidden = true
            }
        )
    }
}