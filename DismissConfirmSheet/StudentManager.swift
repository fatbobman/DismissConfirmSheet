//
//  StudentManager.swift
//  StudentMangement
//
//  Created by Yang Xu on 2020/9/4.
//

import SwiftUI

struct StudentManager: View {
    @EnvironmentObject var store:Store
    @EnvironmentObject var sheetManager:AIOSheetManager
    @State var action:StudentAction
    let student:Student?
    
    private let defaultState:MyState
    @State private var myState:MyState
    @State private var errors:[String] = []
    @State private var confirm = false{
        didSet{
            //控制sheet是否允许dismiss
            if action == .show {
                sheetManager.unlock = true
            }
            else {
                sheetManager.unlock = !confirm
            }
        }
    }
    @State private var delConfirm = false
    
    @Environment(\.presentationMode) var presentationMode
    
    init(action:StudentAction,student:Student?){
        _action = State(wrappedValue: action)
        self.student = student
        
        switch action{
        case .new:
            self.defaultState = MyState(name: "",sex:0, birthday: Date())
            _myState = State(wrappedValue: MyState(name: "", sex:0, birthday: Date()))
        case .edit,.show:
            self.defaultState = MyState(name: student?.name ?? "", sex:Int(student?.sex ?? 0) , birthday: student?.birthday ?? Date())
            _myState = State(wrappedValue: MyState(name: student?.name ?? "", sex:Int(student?.sex ?? 0), birthday: student?.birthday ?? Date()))
        }
    }
    var body: some View{
        NavigationView{
            Form{
                nameView()
                sexView()
                birthdayView()
                errorView()
            }
            .navigationTitle(getTitle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading){
                    HStack{
                    Button("取消"){
                        if !confirm || action == .show{
                        presentationMode.wrappedValue.dismiss()
                        }
                        else {
                            delConfirm.toggle()
                        }
                    }
                    
                    if action != .new{
                        Button("删除"){
                            presentationMode.wrappedValue.dismiss()
                            store.delStudent(student: student!)
                        }
                    }
                    }
                }
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing){
                    if action == .show {
                        Button("编辑"){
                            action = .edit
                            confirm = false
                            sheetManager.dismissControl = true
                        }
                    }
                    else {
                    Button("确定"){
                        if action == .new {
                        presentationMode.wrappedValue.dismiss()
                        store.newStudent(viewModel: myState)
                        }
                        if action == .edit{
                            presentationMode.wrappedValue.dismiss()
                            store.editStudent(viewModel: myState, student: student!)
                        }
                    }
                    .disabled(!confirm)
                    }
                }
            }
            .onChange(of: myState){ _ in
                confirm =  checkAll()
            }
            .onAppear{
                confirm =  checkAll()
            }
            .onReceive(sheetManager.dismissed){ value in
                delConfirm.toggle()
            }
            .alert(isPresented: $delConfirm){
                delAlert()
            }
        }

    }
    
    func delAlert() -> Alert{
        let delButton = Alert.Button.destructive(Text("舍弃")){
            presentationMode.wrappedValue.dismiss()
        }
        let cancelButton = Alert.Button.cancel()
        return Alert(title: Text("有未保存的修改"), message: nil,primaryButton: delButton, secondaryButton: cancelButton)
    }
    
    func getTitle() -> String{
        switch action{
        case .show:
            return "档案信息"
        case .edit:
            return "编辑档案"
        case .new:
            return "新建档案"
        }
    }
    
    func nameView() -> some View{
        HStack{
            Text("姓名:")
            if action == .show {
                Spacer()
                Text(defaultState.name)
            }
            else {
                TextField("学生姓名",text:$myState.name)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
    func sexView() -> some View{
        Group{
            if action == .show {
                HStack{
                    Text("性别:")
                    Spacer()
                    if defaultState.sex == 1 {
                        Text("男")
                    }
                    if defaultState.sex == 2 {
                        Text("女")
                    }
                    
                }
            }
            else {
                HStack{
                    Text("性别:")
                    Picker("性别",selection:$myState.sex){
                        Text("男").tag(1)
                        Text("女").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .labelsHidden()
                }
            }
        }
    }
    
    func birthdayView() -> some View{
        Group{
            if action == .show {
                HStack{
                Text("出生日期")
                Spacer()
                Text(defaultState.birthday,style: .date)
                }
            }
            else {
                DatePicker("出生日期",selection:$myState.birthday)
            }
        }
    }
    
    func errorView() -> some View {
        Section{
            ForEach(errors,id:\.self){ error in
                Text(error)
                    .foregroundColor(.red)
            }
        }
    }
    
    func checkAll() -> Bool {
        if action == .show {return true}
        errors.removeAll()
        let r1 = checkName()
        let r2 = checkSex()
        let r3 = checkBirthday()
        let r4 = checkChange()
        return r1&&r2&&r3&&r4
    }
    
    
    func checkName() -> Bool {
        if myState.name.isEmpty {
            errors.append("必须填写姓名")
            return false
        }
        else{
            return true
        }
    }
    
    func checkSex() -> Bool {
        if  myState.sex == 1 || myState.sex == 2 {
            return true
        }
        else {
            errors.append("请选择性别")
            return false
        }
    }
    
    func checkBirthday() -> Bool {
        //这里就没做判断了,通常我对时间做判断会采用swiftDate
        return true
    }
    
    func checkChange() -> Bool{
        return defaultState != myState
    }
    
}

struct StudentManager_Previews: PreviewProvider {
    static var previews: some View {
        StudentManager(action: .new, student: nil)
    }
}

enum StudentAction{
    case show,edit,new
}

struct MyState:Equatable{
    var name:String
    var sex:Int
    var birthday:Date
}
