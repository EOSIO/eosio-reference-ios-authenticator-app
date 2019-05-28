using_local_pods = ENV['USE_LOCAL_PODS'] == 'true' || false

platform :ios, '12.0'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

def set_up_local_pods
    pod 'EosioSwift', :path => '../eosio-swift'
    pod 'EosioSwiftAbieosSerializationProvider', :path => '../eosio-swift-abieos-serialization-provider'
    pod 'EosioSwiftVault', :path => '../eosio-swift-vault'
    pod 'EosioSwiftEcc', :path => '../eosio-swift-ecc'
    pod 'EosioSwiftVaultSignatureProvider', :path => '../eosio-swift-vault-signature-provider'
    pod 'EosioSwiftReferenceAuthenticatorSignatureProvider', :path => '../eosio-swift-reference-ios-authenticator-signature-provider'
end

def set_up_remote_pods
    pod 'EosioSwift', '~> 0.1.1'
    pod 'EosioSwiftAbieosSerializationProvider', '~> 0.1.1'
    pod 'EosioSwiftVault', '~> 0.1.1'
    pod 'EosioSwiftEcc', '~> 0.1.1'
    pod 'EosioSwiftVaultSignatureProvider', '~> 0.1.1'
    pod 'EosioSwiftReferenceAuthenticatorSignatureProvider', '~> 0.1.1'
end

if using_local_pods
    # Pull pods from sibling directories if using local pods
    target 'EosioReferenceAuthenticator' do
        # Pods for EosioReferenceAuthenticator
        set_up_local_pods
        pod 'ReachabilitySwift'
    end

    target 'EosioReferenceAuthenticatorTests' do
        inherit! :search_paths
        # Pods for testing
        set_up_local_pods
        pod 'SnapshotTesting', '~> 1.1'
    end

    target 'EosioReferenceAuthenticatorUITests' do
        inherit! :search_paths
        # Pods for testing, must be all pods
        set_up_local_pods
    end
else
    # Pull pods from sources above if not using local pods
    target 'EosioReferenceAuthenticator' do
        # Pods for EosioReferenceAuthenticator
        set_up_remote_pods
        pod 'ReachabilitySwift'
    end

    target 'EosioReferenceAuthenticatorTests' do
        inherit! :search_paths
        # Pods for testing
        set_up_remote_pods
        pod 'SnapshotTesting', '~> 1.1'
    end

    target 'EosioReferenceAuthenticatorUITests' do
        inherit! :search_paths
        # Pods for testing, must be all pods
        set_up_remote_pods
    end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        end
    end
end
