# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

def shared_pods
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    pod 'LhHelpers'
    pod 'SwiftyJSON'
    # Pods for Lift Tracker
    pod 'Firebase/Core'
    pod 'Firebase/AdMob'
    pod 'Firebase/Auth'
    pod 'Firebase/Database'
    pod 'FirebaseUI/Auth'
    
    pod 'Tabman', '~> 1.10'
    pod 'Pageboy', '~> 2.6'
    pod 'FirebaseUI/Google'
    pod 'ScrollableGraphView'
end

target 'Lift Tracker' do
    shared_pods
end

target 'Lift TrackerTests' do
    shared_pods
end

