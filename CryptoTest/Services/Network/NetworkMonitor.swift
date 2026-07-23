//
//  NetworkMonitor.swift
//  CryptoTest
//
//  Created by Kiko on 22/07/2026.
//

import Network
import Observation

@MainActor
@Observable
final class NetworkMonitor {

    private(set) var path: NWPath?
    private var monitor: NWPathMonitor?

    /// `nil` path means no update has arrived yet — treat as connected
    /// so the offline banner doesn't flash at launch or in previews.
    var isConnected: Bool {
        guard let path else { return true }
        return path.status == .satisfied
    }

    var unsatisfiedReasonDescription: String? {
        guard let path, path.status == .unsatisfied else { return nil }
        return path.unsatisfiedReason.description
    }

    func startMonitor() async {
        print("NetworkMonitor: startMonitor() begin")
        for await path in pathUpdatesStream() {
            print("NetworkMonitor: received path update — status: \(path.status)")
            self.path = path
            print("NetworkMonitor: isConnected is now \(isConnected)")
        }
        print("NetworkMonitor: startMonitor() loop ended")
    }

    func stopMonitor() {
        print("NetworkMonitor: stopMonitor() — cancelling \(String(describing: monitor))")
        monitor?.cancel()
        monitor = nil
    }

    func refresh() {
        Task { await startMonitor() }
    }

    private func pathUpdatesStream() -> AsyncStream<NWPath> {
        AsyncStream { continuation in
            monitor = NWPathMonitor()
            print("NetworkMonitor: created \(String(describing: monitor))")

            monitor?.pathUpdateHandler = { path in
                print("NetworkMonitor: pathUpdateHandler fired — status: \(path.status)")
                continuation.yield(path)
            }
            monitor?.start(queue: .global(qos: .background))
            print("NetworkMonitor: monitor.start() called")

            continuation.onTermination = { reason in
                print("NetworkMonitor: stream terminated — reason: \(reason)")
                Task { @MainActor in
                    self.stopMonitor()
                }
            }
        }
    }
}

extension NWPath.UnsatisfiedReason {
    var description: String {
        switch self {
        case .notAvailable:
            return "Network not available"
        case .cellularDenied:
            return "Cellular access denied"
        case .wifiDenied:
            return "Wi-Fi access denied"
        case .localNetworkDenied:
            return "Local network access denied"
        case .vpnInactive:
            return "VPN required but inactive"
        @unknown default:
            return "Unknown reason"
        }
    }
}
