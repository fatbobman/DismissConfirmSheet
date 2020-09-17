//
//  AllInOneSheet.swift
//  DataNote
//
//  Created by Yang Xu on 2020/9/11.
//


//支持fullsheet,sheet
//sheet允许动态锁定禁止下滑

import SwiftUI
import Combine

public class AIOSheetManager:ObservableObject{
    @Published var action:AllInOneSheetAction? = nil
    var unlock:Bool = false //false时无法下滑dismiss,由form程序维护
    var type:AllInOneSheetType = .sheet //sheet or fullScreenCover
    var dismissControl:Bool = true //是否启动dismiss阻止开关,true启动阻止
    
    @Published var showSheet = false
    @Published var showFullCoverScreen = false
    
    var dismissed = PassthroughSubject<Bool,Never>()
    var dismissAction:(() -> Void)? = nil
    
    enum AllInOneSheetType{
        case fullScreenCover
        case sheet
    }
}



struct XSheet:ViewModifier{
    @EnvironmentObject var manager:AIOSheetManager
    @EnvironmentObject var store:Store
    @Environment(\.managedObjectContext) var context
    var onDismiss:()->Void{
        return {
            (manager.dismissAction ?? {})()
            manager.dismissAction = nil
            manager.action = nil
            manager.showSheet = false
            manager.showFullCoverScreen = false
        }
    }
    func body(content: Content) -> some View {
        ZStack{
            content
            
            Color.clear
                .sheet(isPresented: $manager.showSheet,onDismiss: onDismiss){
                        if let action = manager.action
                        {
                            reducer(action)
                            .allowAutoDismiss(manager)
                            .environmentObject(manager)
                        }
                    
                }
            
            Color.clear
                .fullScreenCover(isPresented: $manager.showFullCoverScreen,onDismiss: onDismiss){
                        if let action = manager.action
                        {
                            reducer(action)
                                .allowAutoDismiss(manager)
                                .environmentObject(manager)
                        }
                }
        }
        .onChange(of: manager.action){ action in
            guard action != nil else {
                manager.showSheet = false
                manager.showFullCoverScreen = false
                return
            }
            if manager.type == .sheet {
                manager.showSheet = true
            }
            if manager.type == .fullScreenCover{
                manager.showFullCoverScreen = true
            }
        }
    }
}

enum AllInOneSheetAction:Identifiable,Equatable{
    case show(student:Student)
    case edit(student:Student)
    case new
    
    
    var id:UUID{UUID()}
}

extension XSheet{
    func reducer(_ action:AllInOneSheetAction) -> some View{
        switch action{
        case .show(let student):
            return StudentManager(action:.show, student:student)
        case .new:
            return StudentManager(action: .new, student: nil)
        case .edit(let student):
            return StudentManager(action:.edit,student: student)
        }
    }
}

extension View{
    func xsheet() -> some View{
        self
            .modifier(XSheet())
    }
}
