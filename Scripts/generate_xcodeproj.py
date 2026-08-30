#!/usr/bin/env python3
"""Generate iAssets.xcodeproj/project.pbxproj"""
import os
import uuid

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def nid():
    return uuid.uuid4().hex[:24].upper()


files = [
    "iAssetsApp.swift",
    "MainTabView.swift",
    "Models/AssetEnums.swift",
    "Models/AssetItem.swift",
    "Models/NetWorthSnapshot.swift",
    "Services/AppSettingsStore.swift",
    "Services/ExchangeRateService.swift",
    "Services/AssetCalculator.swift",
    "Services/ImportExportService.swift",
    "Services/CloudSyncMonitor.swift",
    "Views/Dashboard/DashboardView.swift",
    "Views/Cabinet/CabinetView.swift",
    "Views/Cabinet/AssetDetailView.swift",
    "Views/Cabinet/SellAssetView.swift",
    "Views/Add/AddAssetView.swift",
    "Views/Review/ReviewView.swift",
    "Views/Settings/SettingsView.swift",
    "Views/Onboarding/OnboardingView.swift",
    "Views/Components/CurrencyFormat.swift",
    "Views/Components/StatusChip.swift",
    "Views/Components/AssetCardView.swift",
    "Resources/ImportTemplate.csv",
]

ids = {f: {"file": nid(), "build": nid()} for f in files}
assets_id, assets_build = nid(), nid()
entitlements_id = nid()
product_id = nid()
target_id = nid()
project_id = nid()
sources_phase, resources_phase, frameworks_phase = nid(), nid(), nid()
main_group, products_group, app_group = nid(), nid(), nid()
models_group, services_group, views_group = nid(), nid(), nid()
dashboard_group, cabinet_group, add_group = nid(), nid(), nid()
review_group, settings_group, onboarding_group = nid(), nid(), nid()
components_group, resources_group = nid(), nid()
sources_config, project_config = nid(), nid()
debug_target, release_target = nid(), nid()
debug_project, release_project = nid(), nid()

swift_sources = [f for f in files if f.endswith(".swift")]
csv_files = [f for f in files if f.endswith(".csv")]


def basename(path):
    return os.path.basename(path)


lines = []
lines.append("// !$*UTF8*$!")
lines.append("{")
lines.append("\tarchiveVersion = 1;")
lines.append("\tclasses = {")
lines.append("\t};")
lines.append("\tobjectVersion = 56;")
lines.append("\tobjects = {")
lines.append("")
lines.append("/* Begin PBXBuildFile section */")
for f in swift_sources:
    name = basename(f)
    lines.append(
        f"\t\t{ids[f]['build']} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {ids[f]['file']} /* {name} */; }};"
    )
for f in csv_files:
    name = basename(f)
    lines.append(
        f"\t\t{ids[f]['build']} /* {name} in Resources */ = {{isa = PBXBuildFile; fileRef = {ids[f]['file']} /* {name} */; }};"
    )
lines.append(
    f"\t\t{assets_build} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_id} /* Assets.xcassets */; }};"
)
lines.append("/* End PBXBuildFile section */")
lines.append("")
lines.append("/* Begin PBXFileReference section */")
for f in files:
    name = basename(f)
    ftype = "text" if name.endswith(".csv") else "sourcecode.swift"
    lines.append(
        f'\t\t{ids[f]["file"]} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = {ftype}; path = {name}; sourceTree = "<group>"; }};'
    )
lines.append(
    f'\t\t{assets_id} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};'
)
lines.append(
    f'\t\t{entitlements_id} /* iAssets.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = iAssets.entitlements; sourceTree = "<group>"; }};'
)
lines.append(
    f'\t\t{product_id} /* iAssets.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = iAssets.app; sourceTree = BUILT_PRODUCTS_DIR; }};'
)
lines.append("/* End PBXFileReference section */")
lines.append("")
lines.append("/* Begin PBXFrameworksBuildPhase section */")
lines.append(f"\t\t{frameworks_phase} /* Frameworks */ = {{")
lines.append("\t\t\tisa = PBXFrameworksBuildPhase;")
lines.append("\t\t\tbuildActionMask = 2147483647;")
lines.append("\t\t\tfiles = (")
lines.append("\t\t\t);")
lines.append("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
lines.append("\t\t};")
lines.append("/* End PBXFrameworksBuildPhase section */")
lines.append("")
lines.append("/* Begin PBXGroup section */")
lines.append(f"\t\t{main_group} = {{")
lines.append("\t\t\tisa = PBXGroup;")
lines.append("\t\t\tchildren = (")
lines.append(f"\t\t\t\t{app_group} /* iAssets */,")
lines.append(f"\t\t\t\t{products_group} /* Products */,")
lines.append("\t\t\t);")
lines.append('\t\t\tsourceTree = "<group>";')
lines.append("\t\t};")
lines.append(f"\t\t{products_group} /* Products */ = {{")
lines.append("\t\t\tisa = PBXGroup;")
lines.append("\t\t\tchildren = (")
lines.append(f"\t\t\t\t{product_id} /* iAssets.app */,")
lines.append("\t\t\t);")
lines.append("\t\t\tname = Products;")
lines.append('\t\t\tsourceTree = "<group>";')
lines.append("\t\t};")
lines.append(f"\t\t{app_group} /* iAssets */ = {{")
lines.append("\t\t\tisa = PBXGroup;")
lines.append("\t\t\tchildren = (")
lines.append(f'\t\t\t\t{ids["iAssetsApp.swift"]["file"]} /* iAssetsApp.swift */,')
lines.append(f'\t\t\t\t{ids["MainTabView.swift"]["file"]} /* MainTabView.swift */,')
lines.append(f"\t\t\t\t{models_group} /* Models */,")
lines.append(f"\t\t\t\t{services_group} /* Services */,")
lines.append(f"\t\t\t\t{views_group} /* Views */,")
lines.append(f"\t\t\t\t{resources_group} /* Resources */,")
lines.append(f"\t\t\t\t{assets_id} /* Assets.xcassets */,")
lines.append(f"\t\t\t\t{entitlements_id} /* iAssets.entitlements */,")
lines.append("\t\t\t);")
lines.append("\t\t\tpath = iAssets;")
lines.append('\t\t\tsourceTree = "<group>";')
lines.append("\t\t};")
lines.append(f"\t\t{models_group} /* Models */ = {{")
lines.append("\t\t\tisa = PBXGroup;")
lines.append("\t\t\tchildren = (")
for f in ["Models/AssetEnums.swift", "Models/AssetItem.swift", "Models/NetWorthSnapshot.swift"]:
    lines.append(f'\t\t\t\t{ids[f]["file"]} /* {basename(f)} */,')
lines.append("\t\t\t);")
lines.append("\t\t\tpath = Models;")
lines.append('\t\t\tsourceTree = "<group>";')
lines.append("\t\t};")
lines.append(f"\t\t{services_group} /* Services */ = {{")
lines.append("\t\t\tisa = PBXGroup;")
lines.append("\t\t\tchildren = (")
for f in [
    "Services/AppSettingsStore.swift",
    "Services/ExchangeRateService.swift",
    "Services/AssetCalculator.swift",
    "Services/ImportExportService.swift",
    "Services/CloudSyncMonitor.swift",
]:
    lines.append(f'\t\t\t\t{ids[f]["file"]} /* {basename(f)} */,')
lines.append("\t\t\t);")
lines.append("\t\t\tpath = Services;")
lines.append('\t\t\tsourceTree = "<group>";')
lines.append("\t\t};")
lines.append(f"\t\t{views_group} /* Views */ = {{")
lines.append("\t\t\tisa = PBXGroup;")
lines.append("\t\t\tchildren = (")
lines.append(f"\t\t\t\t{dashboard_group} /* Dashboard */,")
lines.append(f"\t\t\t\t{cabinet_group} /* Cabinet */,")
lines.append(f"\t\t\t\t{add_group} /* Add */,")
lines.append(f"\t\t\t\t{review_group} /* Review */,")
lines.append(f"\t\t\t\t{settings_group} /* Settings */,")
lines.append(f"\t\t\t\t{onboarding_group} /* Onboarding */,")
lines.append(f"\t\t\t\t{components_group} /* Components */,")
lines.append("\t\t\t);")
lines.append("\t\t\tpath = Views;")
lines.append('\t\t\tsourceTree = "<group>";')
lines.append("\t\t};")

def subgroup(gid, name, path, file_list):
    lines.append(f"\t\t{gid} /* {name} */ = {{")
    lines.append("\t\t\tisa = PBXGroup;")
    lines.append("\t\t\tchildren = (")
    for f in file_list:
        lines.append(f'\t\t\t\t{ids[f]["file"]} /* {basename(f)} */,')
    lines.append("\t\t\t);")
    lines.append(f"\t\t\tpath = {path};")
    lines.append('\t\t\tsourceTree = "<group>";')
    lines.append("\t\t};")

subgroup(dashboard_group, "Dashboard", "Dashboard", ["Views/Dashboard/DashboardView.swift"])
subgroup(
    cabinet_group,
    "Cabinet",
    "Cabinet",
    [
        "Views/Cabinet/CabinetView.swift",
        "Views/Cabinet/AssetDetailView.swift",
        "Views/Cabinet/SellAssetView.swift",
    ],
)
subgroup(add_group, "Add", "Add", ["Views/Add/AddAssetView.swift"])
subgroup(review_group, "Review", "Review", ["Views/Review/ReviewView.swift"])
subgroup(settings_group, "Settings", "Settings", ["Views/Settings/SettingsView.swift"])
subgroup(onboarding_group, "Onboarding", "Onboarding", ["Views/Onboarding/OnboardingView.swift"])
subgroup(
    components_group,
    "Components",
    "Components",
    [
        "Views/Components/CurrencyFormat.swift",
        "Views/Components/StatusChip.swift",
        "Views/Components/AssetCardView.swift",
    ],
)
subgroup(resources_group, "Resources", "Resources", ["Resources/ImportTemplate.csv"])

lines.append("/* End PBXGroup section */")
lines.append("")
lines.append("/* Begin PBXNativeTarget section */")
lines.append(f"\t\t{target_id} /* iAssets */ = {{")
lines.append("\t\t\tisa = PBXNativeTarget;")
lines.append(
    f'\t\t\tbuildConfigurationList = {sources_config} /* Build configuration list for PBXNativeTarget "iAssets" */;'
)
lines.append("\t\t\tbuildPhases = (")
lines.append(f"\t\t\t\t{sources_phase} /* Sources */,")
lines.append(f"\t\t\t\t{frameworks_phase} /* Frameworks */,")
lines.append(f"\t\t\t\t{resources_phase} /* Resources */,")
lines.append("\t\t\t);")
lines.append("\t\t\tbuildRules = (")
lines.append("\t\t\t);")
lines.append("\t\t\tdependencies = (")
lines.append("\t\t\t);")
lines.append("\t\t\tname = iAssets;")
lines.append("\t\t\tproductName = iAssets;")
lines.append(f"\t\t\tproductReference = {product_id} /* iAssets.app */;")
lines.append('\t\t\tproductType = "com.apple.product-type.application";')
lines.append("\t\t};")
lines.append("/* End PBXNativeTarget section */")
lines.append("")
lines.append("/* Begin PBXProject section */")
lines.append(f"\t\t{project_id} /* Project object */ = {{")
lines.append("\t\t\tisa = PBXProject;")
lines.append("\t\t\tattributes = {")
lines.append("\t\t\t\tBuildIndependentTargetsInParallel = 1;")
lines.append("\t\t\t\tLastSwiftUpdateCheck = 1600;")
lines.append("\t\t\t\tLastUpgradeCheck = 1600;")
lines.append("\t\t\t\tTargetAttributes = {")
lines.append(f"\t\t\t\t\t{target_id} = {{")
lines.append("\t\t\t\t\t\tCreatedOnToolsVersion = 16.0;")
lines.append("\t\t\t\t\t};")
lines.append("\t\t\t\t};")
lines.append("\t\t\t};")
lines.append(
    f'\t\t\tbuildConfigurationList = {project_config} /* Build configuration list for PBXProject "iAssets" */;'
)
lines.append('\t\t\tcompatibilityVersion = "Xcode 14.0";')
lines.append("\t\t\tdevelopmentRegion = en;")
lines.append("\t\t\thasScannedForEncodings = 0;")
lines.append("\t\t\tknownRegions = (")
lines.append("\t\t\t\ten,")
lines.append("\t\t\t\tBase,")
lines.append('\t\t\t\t"zh-Hans",')
lines.append("\t\t\t);")
lines.append(f"\t\t\tmainGroup = {main_group};")
lines.append(f"\t\t\tproductRefGroup = {products_group} /* Products */;")
lines.append('\t\t\tprojectDirPath = "";')
lines.append('\t\t\tprojectRoot = "";')
lines.append("\t\t\ttargets = (")
lines.append(f"\t\t\t\t{target_id} /* iAssets */,")
lines.append("\t\t\t);")
lines.append("\t\t};")
lines.append("/* End PBXProject section */")
lines.append("")
lines.append("/* Begin PBXResourcesBuildPhase section */")
lines.append(f"\t\t{resources_phase} /* Resources */ = {{")
lines.append("\t\t\tisa = PBXResourcesBuildPhase;")
lines.append("\t\t\tbuildActionMask = 2147483647;")
lines.append("\t\t\tfiles = (")
lines.append(f"\t\t\t\t{assets_build} /* Assets.xcassets in Resources */,")
for f in csv_files:
    lines.append(f'\t\t\t\t{ids[f]["build"]} /* {basename(f)} in Resources */,')
lines.append("\t\t\t);")
lines.append("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
lines.append("\t\t};")
lines.append("/* End PBXResourcesBuildPhase section */")
lines.append("")
lines.append("/* Begin PBXSourcesBuildPhase section */")
lines.append(f"\t\t{sources_phase} /* Sources */ = {{")
lines.append("\t\t\tisa = PBXSourcesBuildPhase;")
lines.append("\t\t\tbuildActionMask = 2147483647;")
lines.append("\t\t\tfiles = (")
for f in swift_sources:
    lines.append(f'\t\t\t\t{ids[f]["build"]} /* {basename(f)} in Sources */,')
lines.append("\t\t\t);")
lines.append("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
lines.append("\t\t};")
lines.append("/* End PBXSourcesBuildPhase section */")
lines.append("")
lines.append("/* Begin XCBuildConfiguration section */")

common_target = """
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = iAssets/iAssets.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = iAssets;
				INFOPLIST_KEY_LSRequiresIPhoneOS = YES;
				INFOPLIST_KEY_NSPhotoLibraryUsageDescription = "Select photos for your asset showcase.";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = app.iassets.ios;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = 1;
"""

lines.append(f"\t\t{debug_project} /* Debug */ = {{")
lines.append("\t\t\tisa = XCBuildConfiguration;")
lines.append("\t\t\tbuildSettings = {")
lines.append("\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;")
lines.append("\t\t\t\tCLANG_ENABLE_MODULES = YES;")
lines.append("\t\t\t\tCOPY_PHASE_STRIP = NO;")
lines.append("\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;")
lines.append("\t\t\t\tENABLE_TESTABILITY = YES;")
lines.append("\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;")
lines.append("\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;")
lines.append("\t\t\t\tONLY_ACTIVE_ARCH = YES;")
lines.append("\t\t\t\tSDKROOT = iphoneos;")
lines.append('\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";')
lines.append('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";')
lines.append("\t\t\t};")
lines.append("\t\t\tname = Debug;")
lines.append("\t\t};")
lines.append(f"\t\t{release_project} /* Release */ = {{")
lines.append("\t\t\tisa = XCBuildConfiguration;")
lines.append("\t\t\tbuildSettings = {")
lines.append("\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;")
lines.append("\t\t\t\tCLANG_ENABLE_MODULES = YES;")
lines.append("\t\t\t\tCOPY_PHASE_STRIP = NO;")
lines.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
lines.append("\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;")
lines.append("\t\t\t\tSDKROOT = iphoneos;")
lines.append("\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;")
lines.append("\t\t\t\tVALIDATE_PRODUCT = YES;")
lines.append("\t\t\t};")
lines.append("\t\t\tname = Release;")
lines.append("\t\t};")
lines.append(f"\t\t{debug_target} /* Debug */ = {{")
lines.append("\t\t\tisa = XCBuildConfiguration;")
lines.append("\t\t\tbuildSettings = {")
lines.append(common_target)
lines.append("\t\t\t};")
lines.append("\t\t\tname = Debug;")
lines.append("\t\t};")
lines.append(f"\t\t{release_target} /* Release */ = {{")
lines.append("\t\t\tisa = XCBuildConfiguration;")
lines.append("\t\t\tbuildSettings = {")
lines.append(common_target)
lines.append("\t\t\t};")
lines.append("\t\t\tname = Release;")
lines.append("\t\t};")
lines.append("/* End XCBuildConfiguration section */")
lines.append("")
lines.append("/* Begin XCConfigurationList section */")
lines.append(f'\t\t{project_config} /* Build configuration list for PBXProject "iAssets" */ = {{')
lines.append("\t\t\tisa = XCConfigurationList;")
lines.append("\t\t\tbuildConfigurations = (")
lines.append(f"\t\t\t\t{debug_project} /* Debug */,")
lines.append(f"\t\t\t\t{release_project} /* Release */,")
lines.append("\t\t\t);")
lines.append("\t\t\tdefaultConfigurationIsVisible = 0;")
lines.append("\t\t\tdefaultConfigurationName = Release;")
lines.append("\t\t};")
lines.append(
    f'\t\t{sources_config} /* Build configuration list for PBXNativeTarget "iAssets" */ = {{'
)
lines.append("\t\t\tisa = XCConfigurationList;")
lines.append("\t\t\tbuildConfigurations = (")
lines.append(f"\t\t\t\t{debug_target} /* Debug */,")
lines.append(f"\t\t\t\t{release_target} /* Release */,")
lines.append("\t\t\t);")
lines.append("\t\t\tdefaultConfigurationIsVisible = 0;")
lines.append("\t\t\tdefaultConfigurationName = Release;")
lines.append("\t\t};")
lines.append("/* End XCConfigurationList section */")
lines.append("\t};")
lines.append(f"\trootObject = {project_id} /* Project object */;")
lines.append("}")

out_dir = os.path.join(ROOT, "iAssets.xcodeproj")
os.makedirs(out_dir, exist_ok=True)
out_path = os.path.join(out_dir, "project.pbxproj")
with open(out_path, "w", encoding="utf-8") as fh:
    fh.write("\n".join(lines) + "\n")
print(f"Wrote {out_path}")
