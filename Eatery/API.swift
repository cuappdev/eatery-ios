//  This file was automatically generated and should not be edited.

import Apollo

public final class AllEateriesQuery: GraphQLQuery {
  public let operationDefinition =
    "query AllEateries {\n  eateries {\n    __typename\n    id\n    name\n    paymentMethods {\n      __typename\n      swipes\n      brbs\n      cash\n      credit\n      cornellCard\n      mobile\n    }\n    coordinates {\n      __typename\n      latitude\n      longitude\n    }\n    operatingHours {\n      __typename\n      date\n      events {\n        __typename\n        startTime\n        endTime\n        description\n        menu {\n          __typename\n          category\n          items {\n            __typename\n            item\n            healthy\n          }\n        }\n      }\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("eateries", type: .list(.object(Eatery.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(eateries: [Eatery?]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "eateries": eateries.flatMap { (value: [Eatery?]) -> [ResultMap?] in value.map { (value: Eatery?) -> ResultMap? in value.flatMap { (value: Eatery) -> ResultMap in value.resultMap } } }])
    }

    public var eateries: [Eatery?]? {
      get {
        return (resultMap["eateries"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Eatery?] in value.map { (value: ResultMap?) -> Eatery? in value.flatMap { (value: ResultMap) -> Eatery in Eatery(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [Eatery?]) -> [ResultMap?] in value.map { (value: Eatery?) -> ResultMap? in value.flatMap { (value: Eatery) -> ResultMap in value.resultMap } } }, forKey: "eateries")
      }
    }

    public struct Eatery: GraphQLSelectionSet {
      public static let possibleTypes = ["EateryType"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("paymentMethods", type: .object(PaymentMethod.selections)),
        GraphQLField("coordinates", type: .nonNull(.object(Coordinate.selections))),
        GraphQLField("operatingHours", type: .nonNull(.list(.object(OperatingHour.selections)))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: Int, name: String, paymentMethods: PaymentMethod? = nil, coordinates: Coordinate, operatingHours: [OperatingHour?]) {
        self.init(unsafeResultMap: ["__typename": "EateryType", "id": id, "name": name, "paymentMethods": paymentMethods.flatMap { (value: PaymentMethod) -> ResultMap in value.resultMap }, "coordinates": coordinates.resultMap, "operatingHours": operatingHours.map { (value: OperatingHour?) -> ResultMap? in value.flatMap { (value: OperatingHour) -> ResultMap in value.resultMap } }])
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

      public var paymentMethods: PaymentMethod? {
        get {
          return (resultMap["paymentMethods"] as? ResultMap).flatMap { PaymentMethod(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "paymentMethods")
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

      public struct Coordinate: GraphQLSelectionSet {
        public static let possibleTypes = ["CoordinatesType"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("latitude", type: .nonNull(.scalar(Int.self))),
          GraphQLField("longitude", type: .nonNull(.scalar(Int.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(latitude: Int, longitude: Int) {
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

        public var latitude: Int {
          get {
            return resultMap["latitude"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "latitude")
          }
        }

        public var longitude: Int {
          get {
            return resultMap["longitude"]! as! Int
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
            GraphQLField("menu", type: .nonNull(.list(.object(Menu.selections)))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(startTime: String, endTime: String, description: String, menu: [Menu?]) {
            self.init(unsafeResultMap: ["__typename": "EventType", "startTime": startTime, "endTime": endTime, "description": description, "menu": menu.map { (value: Menu?) -> ResultMap? in value.flatMap { (value: Menu) -> ResultMap in value.resultMap } }])
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