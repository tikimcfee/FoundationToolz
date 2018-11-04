import Foundation

public var preferredLanguage: String
{
    return Bundle.main.preferredLocalizations.first?.uppercased() ?? "DE"
}

public var appVersion: String?
{
    if let infoDictionary = Bundle.main.infoDictionary,
        let versionString = infoDictionary["CFBundleShortVersionString"] as? String
    {
        return versionString
    }
    
    return nil
}

public var appBuildNumber: String?
{
    if let infoDictionary = Bundle.main.infoDictionary,
        let buildNumberString = infoDictionary["CFBundleVersion"] as? String
    {
        return buildNumberString
    }
    
    return nil
}

public var appName: String? =
{
    guard let key: String = kCFBundleNameKey as String? else { return nil }
    
    return Bundle.main.infoDictionary?[key] as? String
}()
