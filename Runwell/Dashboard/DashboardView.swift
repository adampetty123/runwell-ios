import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var session: Session
    @State private var companies: [Company] = []
    @State private var loading = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                if loading {
                    ProgressView().tint(Theme.ink)
                } else if let error {
                    Text(error).foregroundColor(Theme.muted).padding()
                } else {
                    List {
                        ForEach(companies) { co in
                            NavigationLink(value: co) { CompanyRow(company: co) }
                                .listRowBackground(Theme.soft)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Companies")
            .navigationDestination(for: Company.self) { AgentListView(company: $0) }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Log out") { Task { await session.logout() } }
                        .foregroundColor(Theme.muted)
                }
            }
            .task { await load() }
            .refreshable { await load() }
        }
    }

    private func load() async {
        do { companies = try await APIClient.shared.companies(); error = nil }
        catch { self.error = (error as? APIError)?.message ?? "Couldn't load companies" }
        loading = false
    }
}

struct CompanyRow: View {
    let company: Company
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 9)
                .fill(Theme.line)
                .frame(width: 34, height: 34)
                .overlay(Text(company.name.prefix(1)).foregroundColor(Theme.ink).font(.headline))
            VStack(alignment: .leading, spacing: 2) {
                Text(company.name).foregroundColor(Theme.ink).font(Theme.font.weight(.medium))
                if let p = company.product { Text(p).foregroundColor(Theme.faint).font(.footnote) }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AgentListView: View {
    let company: Company
    @State private var agents: [Agent] = []
    @State private var loading = true

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            if loading { ProgressView().tint(Theme.ink) }
            else {
                List {
                    ForEach(agents) { a in
                        NavigationLink(value: a) {
                            HStack {
                                Text(a.name).foregroundColor(Theme.ink)
                                if a.isCeo == true { Text("CEO").font(.caption2).foregroundColor(Theme.faint) }
                            }
                        }
                        .listRowBackground(Theme.soft)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle(company.name)
        .navigationDestination(for: Agent.self) { AgentChatView(company: company, agent: $0) }
        .task {
            agents = (try? await APIClient.shared.agents(company.id)) ?? []
            loading = false
        }
    }
}
