import Foundation
import CoreData

extension BuildingEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BuildingEntity> {
        return NSFetchRequest<BuildingEntity>(entityName: "BuildingEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var type: String?
    @NSManaged public var state: String?
    @NSManaged public var positionX: Double
    @NSManaged public var positionY: Double
    @NSManaged public var level: Int16
    @NSManaged public var constructionStartTime: Date?
    @NSManaged public var lastGoldGeneration: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var town: TownEntity?
}
