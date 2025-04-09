struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    var amount: Int
    var currency: String
    
    // Exchange Rate [USD->Others]
    static let fromUSD: [String: Double] = [
        "USD": 1.0,
        "GBP": 0.5,
        "EUR": 1.5,
        "CAN": 1.25
    ]
    
    // Exchange Rate [Others->USD]
    static let toUSD: [String: Double] = [
        "USD": 1.0,
        "GBP": 2.0,
        "EUR": 2.0/3.0,
        "CAN": 0.8
    ]
    
    func convert(_ newCurrency: String) -> Money {
        // safty option for extract rate and unsupport currency check
        guard let toUSDRate = Money.toUSD[currency],
              let fromUSDRate = Money.fromUSD[newCurrency] else {
            // check unsupported currency type
            print("Unsupported Exchange Currency")
            return self
        }
        
        // exchange
        let inUSD = Double(amount) * toUSDRate  // exchange currency to USD
        let inNewCurrency = Int(inUSD * fromUSDRate)  // exchange from USD to new currency
        
        return Money(amount: inNewCurrency, currency: newCurrency)
    }
    
    // X.add(Y) is convert X into Y, total is in currency Y
    func add(_ new: Money) -> Money {
        let convertedSelf = self.convert(new.currency)  // convert X currency into Y
        let totalAmount = convertedSelf.amount + new.amount  // add converted with Y
        return Money(amount: totalAmount, currency: new.currency)
    }

    func subtract(_ new: Money) -> Money {
        let convertedSelf = self.convert(new.currency)  // convert X currency into Y
        let totalAmount = convertedSelf.amount - new.amount  // subtract converted with Y
        return Money(amount: totalAmount, currency: new.currency)
    }
}

////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    // local title and type
    var title: String
    var type: JobType
    
    // initialization
    public init(title: String, type: JobType) {
        self.title = title
        self.type = type
    }
    
    public func calculateIncome(_ hours: Int) -> Int {
        switch type {
        case let .Hourly(hourlyRate):
            return Int(hourlyRate * Double(hours))
        case let .Salary(salary):
            return Int(salary)  // no matter working hours, salary doesn't change
        }
    }

    // raise by amount
    public func raise(byAmount raiseAmount: Double) {
        switch type {
        case let .Hourly(hourlyRate):
            self.type = .Hourly(hourlyRate + raiseAmount)  // update new hourly rate
        case let .Salary(salary):
            self.type = .Salary(salary + UInt(raiseAmount))  // update new salary
        }
    }

    // raise by percentage
    public func raise(byPercent raisePercent: Double) {
        switch type {
        case let .Hourly(hourlyRate):
            self.type = .Hourly(hourlyRate * (1.0 + raisePercent)) // update new hourly rate
        case let .Salary(salary):
            self.type = .Salary(UInt(Double(salary) * (1.0 + raisePercent))) // update new salary
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    public var firstName: String
    public var lastName: String
    public var age: Int
    public var job: Job? {  // can be nil
        didSet {
            if age < 16 {  // legal youngest age of worker
                job = nil
            }
        }
    }
    public var spouse: Person? {  // can be nil
        didSet {
            if age < 18 {  // legal youngest of marrige
                spouse = nil
            }
        }
    }
    
    // initialization
    public init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
    
    public func toString() -> String {
        let job = self.job != nil ? jobInfo(job!) : "nil"
        let spouse = self.spouse != nil ? self.spouse!.firstName : "nil"
        return "[Person: firstName:\(firstName) lastName:\(lastName) age:\(age) job:\(job) spouse:\(spouse)]"
    }
    
    // a private helper for asking money, no need for job title
    private func jobInfo(_ job: Job) -> String {
        switch job.type {
        case let .Salary(amount):
            return "Salary(\(amount))"
        case let .Hourly(rate):
            return "Hourly(\(rate))"
        }
    }
}

////////////////////////////////////
// Family
//
public class Family {
    public var families: [Person] = []
    private var spouse1: Person
    private var spouse2: Person
    
    public init(spouse1: Person, spouse2: Person) {
        self.spouse1 = spouse1
        self.spouse2 = spouse2
        spouse2.spouse = spouse1
        spouse1.spouse = spouse2
        families.append(contentsOf: [spouse1, spouse2])  // become a couple and add into families
    }
    
    public func haveChild(_ child: Person) -> Bool {
        if spouse1.age >= 21 || spouse2.age >= 21 {  // at lease one of the couple be 21
            families.append(child)  // give them a child
            return true
        } else {
            return false
        }
    }
    
    public func householdIncome() -> Int {
        var totalIncome = 0
        for person in families {
            if let job = person.job {  // traverse all family member with a job
                totalIncome += job.calculateIncome(2000)  // set yearly working hour is 2000 hours
            }
        }
        return totalIncome
    }
}
