import Foundation

public struct AppInformation
{
    public static var name: String? =
    {
        guard let key: String = kCFBundleNameKey as String? else { return nil }
        
        return Bundle.main.infoDictionary?[key] as? String
    }()
    
    /// localiztion language ID
    public static let preferredLanguage = Bundle.main.preferredLocalizations.first?.uppercased() ?? "EN"
    
    public static let version: String? =
    {
        if let infoDictionary = Bundle.main.infoDictionary,
            let versionString = infoDictionary["CFBundleShortVersionString"] as? String
        {
            return versionString
        }
        
        return nil
    }()
    
    public static let buildNumber: String? =
    {
        if let infoDictionary = Bundle.main.infoDictionary,
            let buildNumberString = infoDictionary["CFBundleVersion"] as? String
        {
            return buildNumberString
        }
        
        return nil
    }()
}
