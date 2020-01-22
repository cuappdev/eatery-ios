//  This file was automatically generated and should not be edited.

import Apollo

public final class CampusEateriesQuery: GraphQLQuery {
  public let operationDefinition =
    "query CampusEateries {\n  campusEateries {\n    __typename\n    id\n    name\n    nameShort\n    slug\n    eateryType\n    about\n    phone\n    location\n    campusArea {\n      __typename\n      descriptionShort\n    }\n    paymentMethods {\n      __typename\n      swipes\n      brbs\n      cash\n      credit\n      cornellCard\n      mobile\n    }\n    swipeData {\n      __typename\n      startTime\n      endTime\n      swipeDensity\n      waitTimeLow\n      waitTimeHigh\n    }\n    coordinates {\n      __typename\n      latitude\n      longitude\n    }\n    operatingHours {\n      __typename\n      date\n      events {\n        __typename\n        startTime\n        endTime\n        description\n        calSummary\n        menu {\n          __typename\n          category\n          items {\n            __typename\n            item\n            healthy\n          }\n        }\n      }\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("campusEateries", type: .list(.object(CampusEatery.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(campusEateries: [CampusEatery?]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "campusEateries": campusEateries.flatMap { (value: [CampusEatery?]) -> [ResultMap?] in value.map { (value: CampusEatery?) -> ResultMap? in value.flatMap { (value: CampusEatery) -> ResultMap in value.resultMap } } }])
    }

    public var campusEateries: [CampusEatery?]? {
      get {
        return (resultMap["campusEateries"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [CampusEatery?] in value.map { (value: ResultMap?) -> CampusEatery? in value.flatMap { (value: ResultMap) -> CampusEatery in CampusEatery(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [CampusEatery?]) -> [ResultMap?] in value.map { (value: CampusEatery?) -> ResultMap? in value.flatMap { (value: CampusEatery) -> ResultMap in value.resultMap } } }, forKey: "campusEateries")
      }
    }

    public struct CampusEatery: GraphQLSelectionSet {
      public static let possibleTypes = ["CampusEateryType"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("nameShort", type: .nonNull(.scalar(String.self))),
        GraphQLField("slug", type: .nonNull(.scalar(String.self))),
        GraphQLField("eateryType", type: .nonNull(.scalar(String.self))),
        GraphQLField("about", type: .nonNull(.scalar(String.self))),
        GraphQLField("phone", type: .nonNull(.scalar(String.self))),
        GraphQLField("location", type: .nonNull(.scalar(String.self))),
        GraphQLField("campusArea", type: .nonNull(.object(CampusArea.selections))),
        GraphQLField("paymentMethods", type: .nonNull(.object(PaymentMethod.selections))),
        GraphQLField("swipeData", type: .nonNull(.list(.object(SwipeDatum.selections)))),
        GraphQLField("coordinates", type: .nonNull(.object(Coordinate.selections))),
        GraphQLField("operatingHours", type: .nonNull(.list(.object(OperatingHour.selections)))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: Int, name: String, nameShort: String, slug: String, eateryType: String, about: String, phone: String, location: String, campusArea: CampusArea, paymentMethods: PaymentMethod, swipeData: [SwipeDatum?], coordinates: Coordinate, operatingHours: [OperatingHour?]) {
        self.init(unsafeResultMap: ["__typename": "CampusEateryType", "id": id, "name": name, "nameShort": nameShort, "slug": slug, "eateryType": eateryType, "about": about, "phone": phone, "location": location, "campusArea": campusArea.resultMap, "paymentMethods": paymentMethods.resultMap, "swipeData": swipeData.map { (value: SwipeDatum?) -> ResultMap? in value.flatMap { (value: SwipeDatum) -> ResultMap in value.resultMap } }, "coordinates": coordinates.resultMap, "operatingHours": operatingHours.map { (value: OperatingHour?) -> ResultMap? in value.flatMap { (value: OperatingHour) -> ResultMap in value.resultMap } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: Int {
        get {
          return resultMap["id"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      public var nameShort: String {
        get {
          return resultMap["nameShort"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "nameShort")
        }
      }

      public var slug: String {
        get {
          return resultMap["slug"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "slug")
        }
      }

      public var eateryType: String {
        get {
          return resultMap["eateryType"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "eateryType")
        }
      }

      public var about: String {
        get {
          return resultMap["about"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "about")
        }
      }

      public var phone: String {
        get {
          return resultMap["phone"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "phone")
        }
      }

      public var location: String {
        get {
          return resultMap["location"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "location")
        }
      }

      public var campusArea: CampusArea {
        get {
          return CampusArea(unsafeResultMap: resultMap["campusArea"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "campusArea")
        }
      }

      public var paymentMethods: PaymentMethod {
        get {
          return PaymentMethod(unsafeResultMap: resultMap["paymentMethods"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "paymentMethods")
        }
      }

      public var swipeData: [SwipeDatum?] {
        get {
          return (resultMap["swipeData"] as! [ResultMap?]).map { (value: ResultMap?) -> SwipeDatum? in value.flatMap { (value: ResultMap) -> SwipeDatum in SwipeDatum(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.map { (value: SwipeDatum?) -> ResultMap? in value.flatMap { (value: SwipeDatum) -> ResultMap in value.resultMap } }, forKey: "swipeData")
        }
      }

      public var coordinates: Coordinate {
        get {
          return Coordinate(unsafeResultMap: resultMap["coordinates"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "coordinates")
        }
      }

      public var operatingHours: [OperatingHour?] {
        get {
          return (resultMap["operatingHours"] as! [ResultMap?]).map { (value: ResultMap?) -> OperatingHour? in value.flatMap { (value: ResultMap) -> OperatingHour in OperatingHour(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.map { (value: OperatingHour?) -> ResultMap? in value.flatMap { (value: OperatingHour) -> ResultMap in value.resultMap } }, forKey: "operatingHours")
        }
      }

      public struct CampusArea: GraphQLSelectionSet {
        public static let possibleTypes = ["CampusAreaType"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("descriptionShort", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(descriptionShort: String) {
          self.init(unsafeResultMap: ["__typename": "CampusAreaType", "descriptionShort": descriptionShort])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var descriptionShort: String {
          get {
            return resultMap["descriptionShort"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "descriptionShort")
          }
        }
      }

      public struct PaymentMethod: GraphQLSelectionSet {
        public static let possibleTypes = ["PaymentMethodsType"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("swipes", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("brbs", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("cash", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("credit", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("cornellCard", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("mobile", type: .nonNull(.scalar(Bool.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(swipes: Bool, brbs: Bool, cash: Bool, credit: Bool, cornellCard: Bool, mobile: Bool) {
          self.init(unsafeResultMap: ["__typename": "PaymentMethodsType", "swipes": swipes, "brbs": brbs, "cash": cash, "credit": credit, "cornellCard": cornellCard, "mobile": mobile])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var swipes: Bool {
          get {
            return resultMap["swipes"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "swipes")
          }
        }

        public var brbs: Bool {
          get {
            return resultMap["brbs"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "brbs")
          }
        }

        public var cash: Bool {
          get {
            return resultMap["cash"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "cash")
          }
        }

        public var credit: Bool {
          get {
            return resultMap["credit"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "credit")
          }
        }

        public var cornellCard: Bool {
          get {
            return resultMap["cornellCard"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "cornellCard")
          }
        }

        public var mobile: Bool {
          get {
            return resultMap["mobile"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "mobile")
          }
        }
      }

      public struct SwipeDatum: GraphQLSelectionSet {
        public static let possibleTypes = ["SwipeDataType"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("startTime", type: .nonNull(.scalar(String.self))),
          GraphQLField("endTime", type: .nonNull(.scalar(String.self))),
          GraphQLField("swipeDensity", type: .nonNull(.scalar(Double.self))),
          GraphQLField("waitTimeLow", type: .nonNull(.scalar(Int.self))),
          GraphQLField("waitTimeHigh", type: .nonNull(.scalar(Int.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(startTime: String, endTime: String, swipeDensity: Double, waitTimeLow: Int, waitTimeHigh: Int) {
          self.init(unsafeResultMap: ["__typename": "SwipeDataType", "startTime": startTime, "endTime": endTime, "swipeDensity": swipeDensity, "waitTimeLow": waitTimeLow, "waitTimeHigh": waitTimeHigh])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var startTime: String {
          get {
            return resultMap["startTime"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startTime")
          }
        }

        public var endTime: String {
          get {
            return resultMap["endTime"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endTime")
          }
        }

        public var swipeDensity: Double {
          get {
            return resultMap["swipeDensity"]! as! Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "swipeDensity")
          }
        }

        public var waitTimeLow: Int {
          get {
            return resultMap["waitTimeLow"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "waitTimeLow")
          }
        }

        public var waitTimeHigh: Int {
          get {
            return resultMap["waitTimeHigh"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "waitTimeHigh")
          }
        }
      }

      public struct Coordinate: GraphQLSelectionSet {
        public static let possibleTypes = ["CoordinatesType"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("latitude", type: .nonNull(.scalar(Double.self))),
          GraphQLField("longitude", type: .nonNull(.scalar(Double.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(latitude: Double, longitude: Double) {
          self.init(unsafeResultMap: ["__typename": "CoordinatesType", "latitude": latitude, "longitude": longitude])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var latitude: Double {
          get {
            return resultMap["latitude"]! as! Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "latitude")
          }
        }

        public var longitude: Double {
          get {
            return resultMap["longitude"]! as! Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "longitude")
          }
        }
      }

      public struct OperatingHour: GraphQLSelectionSet {
        public static let possibleTypes = ["OperatingHoursType"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("date", type: .nonNull(.scalar(String.self))),
          GraphQLField("events", type: .nonNull(.list(.object(Event.selections)))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(date: String, events: [Event?]) {
          self.init(unsafeResultMap: ["__typename": "OperatingHoursType", "date": date, "events": events.map { (value: Event?) -> ResultMap? in value.flatMap { (value: Event) -> ResultMap in value.resultMap } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var date: String {
          get {
            return resultMap["date"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "date")
          }
        }

        public var events: [Event?] {
          get {
            return (resultMap["events"] as! [ResultMap?]).map { (value: ResultMap?) -> Event? in value.flatMap { (value: ResultMap) -> Event in Event(unsafeResultMap: value) } }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Event?) -> ResultMap? in value.flatMap { (value: Event) -> ResultMap in value.resultMap } }, forKey: "events")
          }
        }

        public struct Event: GraphQLSelectionSet {
          public static let possibleTypes = ["EventType"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("startTime", type: .nonNull(.scalar(String.self))),
            GraphQLField("endTime", type: .nonNull(.scalar(String.self))),
            GraphQLField("description", type: .nonNull(.scalar(String.self))),
            GraphQLField("calSummary", type: .nonNull(.scalar(String.self))),
            GraphQLField("menu", type: .nonNull(.list(.object(Menu.selections)))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(startTime: String, endTime: String, description: String, calSummary: String, menu: [Menu?]) {
            self.init(unsafeResultMap: ["__typename": "EventType", "startTime": startTime, "endTime": endTime, "description": description, "calSummary": calSummary, "menu": menu.map { (value: Menu?) -> ResultMap? in value.flatMap { (value: Menu) -> ResultMap in value.resultMap } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var startTime: String {
            get {
              return resultMap["startTime"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "startTime")
            }
          }

          public var endTime: String {
            get {
              return resultMap["endTime"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "endTime")
            }
          }

          public var description: String {
            get {
              return resultMap["description"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          public var calSummary: String {
            get {
              return resultMap["calSummary"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "calSummary")
            }
          }

          public var menu: [Menu?] {
            get {
              return (resultMap["menu"] as! [ResultMap?]).map { (value: ResultMap?) -> Menu? in value.flatMap { (value: ResultMap) -> Menu in Menu(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.map { (value: Menu?) -> ResultMap? in value.flatMap { (value: Menu) -> ResultMap in value.resultMap } }, forKey: "menu")
            }
          }

          public struct Menu: GraphQLSelectionSet {
            public static let possibleTypes = ["FoodStationType"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("category", type: .nonNull(.scalar(String.self))),
              GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(category: String, items: [Item?]) {
              self.init(unsafeResultMap: ["__typename": "FoodStationType", "category": category, "items": items.map { (value: Item?) -> ResultMap? in value.flatMap { (value: Item) -> ResultMap in value.resultMap } }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var category: String {
              get {
                return resultMap["category"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "category")
              }
            }

            public var items: [Item?] {
              get {
                return (resultMap["items"] as! [ResultMap?]).map { (value: ResultMap?) -> Item? in value.flatMap { (value: ResultMap) -> Item in Item(unsafeResultMap: value) } }
              }
              set {
                resultMap.updateValue(newValue.map { (value: Item?) -> ResultMap? in value.flatMap { (value: Item) -> ResultMap in value.resultMap } }, forKey: "items")
              }
            }

            public struct Item: GraphQLSelectionSet {
              public static let possibleTypes = ["FoodItemType"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("item", type: .nonNull(.scalar(String.self))),
                GraphQLField("healthy", type: .nonNull(.scalar(Bool.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(item: String, healthy: Bool) {
                self.init(unsafeResultMap: ["__typename": "FoodItemType", "item": item, "healthy": healthy])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var item: String {
                get {
                  return resultMap["item"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "item")
                }
              }

              public var healthy: Bool {
                get {
                  return resultMap["healthy"]! as! Bool
                }
                set {
                  resultMap.updateValue(newValue, forKey: "healthy")
                }
              }
            }
          }
        }
      }
    }
  }
}