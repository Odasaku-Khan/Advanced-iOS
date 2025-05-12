import Foundation
import CoreData

extension StoredBook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredBook> {
        return NSFetchRequest<StoredBook>(entityName: "StoredBook")
    }

    @NSManaged public var gutendexId: Int64
    @NSManaged public var title: String?
    @NSManaged public var authors: String?
    @NSManaged public var localFilePath: String?
    @NSManaged public var coverImageURL: String?
    @NSManaged public var downloadDate: Date?
    @NSManaged public var sourceURL: String?
    @NSManaged public var mediaType: String?
}

extension StoredBook : Identifiable {
    public var id: Int64 { gutendexId }
}
