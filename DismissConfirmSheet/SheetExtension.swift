//
//  SheetExtension.swift
//  DataNote
//
//  Created by Yang Xu on 2020/9/11.
//

// https://gist.github.com/mobilinked/9b6086b3760bcf1e5432932dad0813c0

import Foundation
import SwiftUI
import Combine

struct MbModalHackView: UIViewControllerRepresentable {
    let manager:AIOSheetManager
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MbModalHackView>) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<MbModalHackView>) {
        rootViewController(of: uiViewController).presentationController?.delegate = context.coordinator
    }
    
    private func rootViewController(of uiViewController: UIViewController) -> UIViewController {
        if let parent = uiViewController.parent {
            return rootViewController(of: parent)
        }
        else {
            return uiViewController
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(manager: manager)
    }
    
    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        let manager:AIOSheetManager
        init(manager:AIOSheetManager){
            self.manager = manager
        }
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            guard manager.dismissControl else {return true}
            return manager.unlock
        }
        
        //当阻止取消时,发送用户要求取消sheet命令
        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController){
            manager.dismissed.send(true)
        }
    }
}

extension View {
    public func allowAutoDismiss(_ manager:AIOSheetManager) -> some View {
        self
            .background(MbModalHackView(manager: manager))
           
    }
}


