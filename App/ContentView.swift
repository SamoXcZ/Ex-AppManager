import SwiftUI

@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            AppList()
        }
    }
}

struct AppList: View {
    @State private var apps: [AppInfo] = []
    @State private var skippedApps: [String] = []
    @State private var showErrorAlert = false

    var body: some View {
    NavigationView {
        VStack {
            AppListView(apps: apps)
        }
        .navigationTitle("App List")
        .onAppear {
            fetchApps()
        }
    }
}

    func fetchApps() {
    let normalPath = "/var/containers/Bundle/Application/"
    let fileManager = FileManager.default

    var fetchedApps: [AppInfo] = []

    if let normalAppContents = try? fileManager.contentsOfDirectory(atPath: normalPath) {
        for appFolder in normalAppContents {
            if let appInfo = getAppInfo(appFolder: appFolder, basePath: normalPath) {
                fetchedApps.append(appInfo)
            }
        }
    }

    apps = fetchedApps
}

func getAppInfo(appFolder: String, basePath: String) -> AppInfo? {
    let fileManager = FileManager.default
    let appPath = "\(basePath)\(appFolder)/"

    do {
        let appContents = try fileManager.contentsOfDirectory(atPath: appPath)

        if let appBundleFolder = appContents.first(where: { $0.hasSuffix(".app") }) {
            let infoPlistPath = "\(appPath)\(appBundleFolder)/Info.plist"
            let appIconPaths = [
    "\(appPath)\(appBundleFolder)/AppIcon60x60@2x.png",
    "\(appPath)\(appBundleFolder)/icon@2x.png",
    "\(appPath)\(appBundleFolder)/Icon.png",
    "\(appPath)\(appBundleFolder)/ProductionAppIcon60x60@2x.png",
    "\(appPath)\(appBundleFolder)/AppIcon.png",
    "\(appPath)\(appBundleFolder)/logo_gmail_2020q4_color60x60@2x.png",
    "\(appPath)\(appBundleFolder)/logo_authenticator_color60x60@2x.png",
    "\(appPath)\(appBundleFolder)/AppIcon60x60@3x.png",
    "\(appPath)\(appBundleFolder)/logo_youtube_color60x60@2x.png",
"\(appPath)\(appBundleFolder)/New1@2x.png",
"\(appPath)\(appBundleFolder)/AppIcon_TikTok60x60@2x.png",
"\(appPath)\(appBundleFolder)/Icon-Production60x60@2x.png",
"\(appPath)\(appBundleFolder)/AppIcon.Default60x60@3x.png",
]

            if fileManager.fileExists(atPath: infoPlistPath),
               let infoDict = NSDictionary(contentsOfFile: infoPlistPath) as? [String: Any],
               let appName = infoDict["CFBundleName"] as? String,
               let bundleIdentifier = infoDict["CFBundleIdentifier"] as? String {
                let appIconPath = appIconPaths.first { fileManager.fileExists(atPath: $0) }
                return AppInfo(appName: appName, bundleIdentifier: bundleIdentifier, appIconPath: appIconPath)
            } else {
                print("Failed to extract app info for \(appFolder).")
            }
        } else {
            print("No app bundle found in \(appFolder).")
        }
    } catch let error {
        print("Error accessing app info for \(appFolder): \(error)")
    }

    return nil
}
}

struct AppInfo: Identifiable {
    var id = UUID()
    let appName: String
    let bundleIdentifier: String
    let appIconPath: String?

    init(appName: String, bundleIdentifier: String, appIconPath: String? = nil) {
        self.appName = appName
        self.bundleIdentifier = bundleIdentifier
        self.appIconPath = appIconPath
    }
}

struct AppListView: View {
    var apps: [AppInfo]

    var body: some View {
        List(apps) { app in
            HStack {
                if let appIconPath = app.appIconPath,
                   let appIcon = UIImage(contentsOfFile: appIconPath) {
                    Image(uiImage: appIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .cornerRadius(15)
                        .padding(.trailing, 10)
                } else {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(.red)
                        .frame(width: 60, height: 60)
                        .padding(.trailing, 10)
                }

                VStack(alignment: .leading) {
                    Text(app.appName)
                        .font(.headline)
                        .padding(.bottom, 5)
                    Text(app.bundleIdentifier == "" ? "(null)" : app.bundleIdentifier)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(10)
            }
        }
    }
}