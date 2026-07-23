import SwiftUI

struct ScreenStateWrapper<Content: View>: View {

    let title: String
    let offlineMessage: String
    let isEmpty: Bool
    let emptyTitle: String
    let emptySystemImage: String
    let emptyDescription: String
    let load: () async throws -> Void
    var refresh: (() async throws -> Void)? = nil
    @ViewBuilder let content: Content

    @Environment(NetworkMonitor.self) private var networkMonitor

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(
                title: title,
                isOffline: !networkMonitor.isConnected,
                offlineMessage: offlineMessage
            )

            if let errorMessage, !isEmpty, networkMonitor.isConnected {
                ErrorBanner(message: errorMessage) {
                    Task { await performLoad() }
                }
                .padding(.bottom, 6)
            }

            if isLoading && isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if isEmpty, let errorMessage, networkMonitor.isConnected {
                ScrollView {
                    ContentUnavailableView {
                        Label("Couldn't Load \(title)", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Retry") {
                            Task { await performLoad() }
                        }
                    }
                    .containerRelativeFrame(.vertical)
                }
                .refreshable {
                    await performRefresh()
                }
            } else if isEmpty {
                ScrollView {
                    ContentUnavailableView(
                        emptyTitle,
                        systemImage: emptySystemImage,
                        description: Text(emptyDescription)
                    )
                    .containerRelativeFrame(.vertical)
                }
                .refreshable {
                    await performRefresh()
                }
            } else {
                content
                    .refreshable {
                        await performRefresh()
                    }
            }
        }
        .task {
            await performLoad()
        }
        .onChange(of: networkMonitor.isConnected) { wasConnected, isConnected in
            guard !wasConnected, isConnected else { return }
            Task {
                await performLoad()
            }
        }
    }

    private func performLoad() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await load()
            errorMessage = nil
        } catch {
            setError(error)
        }
    }

    private func performRefresh() async {
        do {
            try await (refresh ?? load)()
            errorMessage = nil
        } catch {
            setError(error)
        }
    }

    private func setError(_ error: Error) {
        errorMessage = error.isOfflineError ? nil : error.localizedDescription
    }
}

#Preview("Loaded") {
    ScreenStateWrapper(
        title: "Home",
        offlineMessage: "Offline — showing last synced data",
        isEmpty: false,
        emptyTitle: "No Items",
        emptySystemImage: "tray",
        emptyDescription: "Nothing to show yet.",
        load: {}
    ) {
        List(1...5, id: \.self) { number in
            Text("Item \(number)")
        }
        .listStyle(.plain)
    }
    .environment(NetworkMonitor())
}

#Preview("Loading") {
    ScreenStateWrapper(
        title: "Home",
        offlineMessage: "Offline — showing last synced data",
        isEmpty: true,
        emptyTitle: "No Items",
        emptySystemImage: "tray",
        emptyDescription: "Nothing to show yet.",
        load: {
            try await Task.sleep(for: .seconds(3600))
        }
    ) {
        List(1...5, id: \.self) { number in
            Text("Item \(number)")
        }
        .listStyle(.plain)
    }
    .environment(NetworkMonitor())
}

#Preview("Empty") {
    ScreenStateWrapper(
        title: "Home",
        offlineMessage: "Offline — showing last synced data",
        isEmpty: true,
        emptyTitle: "No Items",
        emptySystemImage: "tray",
        emptyDescription: "Nothing to show yet.",
        load: {}
    ) {
        List(1...5, id: \.self) { number in
            Text("Item \(number)")
        }
        .listStyle(.plain)
    }
    .environment(NetworkMonitor())
}

#Preview("Error — no cached data") {
    ScreenStateWrapper(
        title: "Home",
        offlineMessage: "Offline — showing last synced data",
        isEmpty: true,
        emptyTitle: "No Items",
        emptySystemImage: "tray",
        emptyDescription: "Nothing to show yet.",
        load: {
            throw URLError(.notConnectedToInternet)
        }
    ) {
        List(1...5, id: \.self) { number in
            Text("Item \(number)")
        }
        .listStyle(.plain)
    }
    .environment(NetworkMonitor())
}

#Preview("Error — showing cached data") {
    ScreenStateWrapper(
        title: "Home",
        offlineMessage: "Offline — showing last synced data",
        isEmpty: false,
        emptyTitle: "No Items",
        emptySystemImage: "tray",
        emptyDescription: "Nothing to show yet.",
        load: {
            throw URLError(.notConnectedToInternet)
        }
    ) {
        List(1...5, id: \.self) { number in
            Text("Item \(number)")
        }
        .listStyle(.plain)
    }
    .environment(NetworkMonitor())
}
