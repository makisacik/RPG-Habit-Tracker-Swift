//
//  AddTasksView.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 27.07.2025.
//

import SwiftUI

struct AddTasksView: View {
    @Binding var tasks: [String]
    var onEditTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                onEditTapped()
            }) {
                HStack {
                    Text("Add Tasks")
                        .font(.appFont(size: 16, weight: .black))
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(tasks.count) Tasks")
                        .font(.appFont(size: 14, weight: .regular))
                        .foregroundColor(.white)

                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.yellow)
                }
                .padding()
                .background(
                    Image("panelInset_beige")
                        .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                )
                .cornerRadius(10)
            }
        }
    }
}


struct TaskEditorPopup: View {
    @Binding var tasks: [String]
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Edit Tasks")
                    .font(.appFont(size: 18, weight: .black))
                    .foregroundColor(.black)

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Image("checkbox_brown_cross")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }

            Divider()

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(tasks.indices, id: \.self) { index in
                        HStack {
                            TextField("Task \(index + 1)", text: $tasks[index])
                                .font(.appFont(size: 16))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(
                                    Image("panelInset_beige")
                                        .resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                                )
                                .cornerRadius(8)

                            Button(action: {
                                tasks.remove(at: index)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                                    .padding(.leading, 4)
                            }
                        }
                    }

                    Button(action: {
                        tasks.append("")
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Task")
                                .font(.appFont(size: 14, weight: .black))
                        }
                        .foregroundColor(.yellow)
                    }
                }
            }

            Spacer()

            Button(action: {
                isPresented = false
            }) {
                Text("Done")
                    .font(.appFont(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        Image("buttonLong_beige")
                            .resizable()
                            .frame(height: 40)
                    )
            }
        }
        .padding()
    }
}
