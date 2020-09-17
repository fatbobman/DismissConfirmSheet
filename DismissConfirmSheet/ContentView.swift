//
//  ContentView.swift
//  StudentMangement
//
//  Created by Yang Xu on 2020/9/4.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var store:Store
    @FetchRequest(entity: Student.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: false)]) var students:FetchedResults<Student>
    @EnvironmentObject var sheetManager:AIOSheetManager
    var body: some View {
        NavigationView{
            List{
                ForEach(students){ student in
                    HStack{
                        Button(
                            action:{
                                sheetManager.type = .sheet
                                sheetManager.dismissControl = false
                                sheetManager.action = .show(student: student)
                                
                            }
                        ){
                        HStack{
                            Text(student.name ?? "")
                            if student.sex == 1 {
                                Text("男")
                            }
                            if student.sex == 2 {
                                Text("女")
                            }
                            Text(student.birthday ?? Date(),style: .date)
                        }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .toolbar{
                ToolbarItem(placement:ToolbarItemPlacement.navigationBarTrailing){
                    Button("New"){
                        sheetManager.type = .sheet
                        sheetManager.dismissControl = true
                        sheetManager.action = .new
                    }
                }
            }
            .navigationTitle("Student List")
            .xsheet()
        }
    }
    
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}



