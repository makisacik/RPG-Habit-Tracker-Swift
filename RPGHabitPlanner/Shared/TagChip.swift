//
//  TagChip.swift
//  RPGHabitPlanner
//
//  Created by Mehmet Ali Kısacık on 14.08.2025.
//

import SwiftUI

struct TagChip: View {
    let tag: Tag
    let isSelected: Bool
    let isRemovable: Bool
    let onTap: () -> Void
    let onRemove: (() -> Void)?

    init(
        tag: Tag,
        isSelected: Bool = false,
        isRemovable: Bool = false,
        onTap: @escaping () -> Void,
        onRemove: (() -> Void)? = nil
    ) {
        self.tag = tag
        self.isSelected = isSelected
        self.isRemovable = isRemovable
        self.onTap = onTap
        self.onRemove = onRemove
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: tag.displayIcon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)

                Text(tag.name)
                    .font(.appFont(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                if isRemovable, let onRemove = onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(tag.displayColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TagChipRow: View {
    let tags: [Tag]
    let isSelectable: Bool
    let selectedTags: Set<Tag>
    let onTagTap: (Tag) -> Void
    let onTagRemove: ((Tag) -> Void)?

    init(
        tags: [Tag],
        isSelectable: Bool = false,
        selectedTags: Set<Tag> = [],
        onTagTap: @escaping (Tag) -> Void,
        onTagRemove: ((Tag) -> Void)? = nil
    ) {
        self.tags = tags
        self.isSelectable = isSelectable
        self.selectedTags = selectedTags
        self.onTagTap = onTagTap
        self.onTagRemove = onTagRemove
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(tags) { tag in
                    TagChip(
                        tag: tag,
                        isSelected: isSelectable ? selectedTags.contains(tag) : false,
                        isRemovable: onTagRemove != nil,
                        onTap: { onTagTap(tag) },
                        onRemove: onTagRemove.map { removeAction in
                            { removeAction(tag) }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TagChip(
            tag: Tag(name: "Work", icon: "briefcase", color: "#FF6B6B")
        ) {}

        TagChip(
            tag: Tag(name: "Personal", icon: "heart", color: "#4ECDC4"),
            isSelected: true
        ) {}

        TagChip(
            tag: Tag(name: "Urgent", icon: "exclamationmark.triangle", color: "#FFB347"),
            isRemovable: true,
            onTap: {},
            onRemove: {}
        )

        TagChipRow(
            tags: [
                Tag(name: "Work", icon: "briefcase", color: "#FF6B6B"),
                Tag(name: "Personal", icon: "heart", color: "#4ECDC4"),
                Tag(name: "Urgent", icon: "exclamationmark.triangle", color: "#FFB347"),
                Tag(name: "Study", icon: "book", color: "#96CEB4")
            ],
            isSelectable: true,
            selectedTags: [Tag(name: "Work", icon: "briefcase", color: "#FF6B6B")],
            onTagTap: { _ in },
            onTagRemove: { _ in }
        )
    }
    .padding()
}
