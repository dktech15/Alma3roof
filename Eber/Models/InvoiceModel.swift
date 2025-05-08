

import Foundation
public class Invoice: Model
{
	public var title : String!
	public var subTitle : String!
	public var price : String!
    public var sectionTitle : String!

    required public init(sectionTitle:String = "", title:String, subTitle:String, price:String)
    {
        self.sectionTitle = sectionTitle
        self.title = title
		self.subTitle = subTitle
		self.price = price
	}

	public func dictionaryRepresentation() -> NSDictionary
    {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.title, forKey: "title")
		dictionary.setValue(self.subTitle, forKey: "subTitle")
		dictionary.setValue(self.price, forKey: "price")
		return dictionary
	}

}
