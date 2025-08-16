import Foundation
import CoreData

extension TownEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TownEntity> {
        return NSFetchRequest<TownEntity>(entityName: "TownEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var level: Int16
    @NSManaged public var experience: Int16
    @NSManaged public var maxBuildings: Int16
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var buildings: NSSet?
}

// MARK: Generated accessors for buildings
extension TownEntity {
    @objc(addBuildingsObject:)
    @NSManaged public func addToBuildings(_ value: BuildingEntity)

    @objc(removeBuildingsObject:)
    @NSManaged public func removeFromBuildings(_ value: BuildingEntity)

    @objc(addBuildings:)
    @NSManaged public func addToBuildings(_ values: NSSet)

    @objc(removeBuildings:)
    @NSManaged public func removeFromBuildings(_ values: NSSet)
}
