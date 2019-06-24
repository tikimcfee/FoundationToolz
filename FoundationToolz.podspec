 Pod::Spec.new do |s|
    
    # meta infos
    s.name             = "FoundationToolz"
    s.version          = "1.0.3"
    s.summary          = "Reusable Foundation Tools"
    s.description      = "Some Reusable Tools Based on the Foundation Framework"
    s.homepage         = "http://flowtoolz.com"
    s.license          = 'MIT'
    s.author           = { "Flowtoolz" => "contact@flowtoolz.com" }
    s.source           = {  :git => "https://github.com/flowtoolz/FoundationToolz.git",
                            :tag => s.version.to_s }
    
    # compiler requirements
    s.requires_arc = true
    s.swift_version = '5.0'
    
    # minimum platform SDKs
    s.platforms = {:ios => "11.0", :osx => "10.12", :tvos => "11.0"}

    # minimum deployment targets
    s.ios.deployment_target  = '11.0'
    s.osx.deployment_target = '10.12'
    s.tvos.deployment_target = '11.0'

    # dependencies
    s.dependency 'ReachabilitySwift', '~> 4.3.0'
    
    # sorces
    s.source_files = 'Code/**/*.swift'
end
