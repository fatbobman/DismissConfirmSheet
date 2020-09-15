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
    var action:AllInOneSheetAction? = nil{
        didSet{
            if type == .sheet {
                sheetAction = action
            }
            if type == .fullScreenCover {
                fullScreenAction = action
            }
        }
    }
    var unlock:Bool = false //false时无法下滑dismiss,由form程序维护
    var type:AllInOneSheetType = .sheet //sheet or fullScreenCover
    var dismissControl:Bool = true //是否启动dismiss阻止开关,true启动阻止
    @Published var sheetAction:AllInOneSheetAction? = nil //用于激活sheet的item
    @Published var fullScreenAction:AllInOneSheetAction? = nil //用于激活fullScreenCover的item
    
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
        }
    }
    func body(content: Content) -> some View {
        ZStack{
            content
            
            Color.clear
                .sheet(item: $manager.sheetAction,onDismiss:onDismiss){ action in
                    reducer(action)
                        .allowAutoDismiss(manager)
                        .environmentObject(manager)
                    
                }
            Color.clear
                .fullScreenCover(item: $manager.fullScreenAction,onDismiss:onDismiss){ action in
                    reducer(action)
                        .allowAutoDismiss(manager)
                        .environmentObject(manager)
                }
        }
        
    }
}

enum AllInOneSheetAction:Identifiable{
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
