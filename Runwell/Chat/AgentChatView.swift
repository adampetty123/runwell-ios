import SwiftUI

struct AgentChatView: View {
    let company: Company
    let agent: Agent

    @State private var messages: [ChatMessage] = []
    @State private var tasks: [AgentTask] = []
    @State private var draft = ""
    @State private var tab = Tab.chat
    @State private var sending = false

    enum Tab: String, CaseIterable { case chat = "Chat", tasks = "Tasks" }

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $tab) {
                ForEach(Tab.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(12)

            if tab == .chat { chatView } else { taskView }
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle(agent.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await refresh() }
    }

    private var chatView: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(messages) { m in Bubble(message: m).id(m.id) }
                    }
                    .padding(16)
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last { withAnimation { proxy.scrollTo(last.id, anchor: .bottom) } }
                }
            }
            composer
        }
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Message \(agent.name)…", text: $draft, axis: .vertical)
                .lineLimit(1...6)
                .padding(.horizontal, 12).padding(.vertical, 9)
                .background(Theme.soft).foregroundColor(Theme.ink)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.line, lineWidth: 1))
            Button { Task { await sendMsg() } } label: {
                Image(systemName: "arrow.up")
                    .fontWeight(.semibold).foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(Color(hex: 0x292929)).clipShape(Circle())
            }
            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || sending)
        }
        .padding(12)
    }

    private var taskView: some View {
        List {
            ForEach(tasks) { t in
                VStack(alignment: .leading, spacing: 4) {
                    Text(t.text).foregroundColor(Theme.ink).font(.footnote)
                    Text(t.status).foregroundColor(Theme.faint).font(.caption2)
                }
                .listRowBackground(Theme.soft)
            }
        }
        .scrollContentBackground(.hidden)
        .refreshable { tasks = (try? await APIClient.shared.tasks(company.id, agent.id)) ?? [] }
    }

    private func refresh() async {
        messages = (try? await APIClient.shared.history(company.id, agent.id)) ?? []
        tasks = (try? await APIClient.shared.tasks(company.id, agent.id)) ?? []
    }

    private func sendMsg() async {
        let text = draft.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        sending = true; draft = ""
        try? await APIClient.shared.send(company.id, agent.id, message: text)
        await refresh()
        sending = false
    }
}

struct Bubble: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.isMe { Spacer(minLength: 40) }
            Text(message.text)
                .foregroundColor(message.isMe ? Theme.bg : Theme.ink)
                .padding(.horizontal, 13).padding(.vertical, 9)
                .background(message.isMe ? Theme.accent : Theme.soft)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            if !message.isMe { Spacer(minLength: 40) }
        }
    }
}
