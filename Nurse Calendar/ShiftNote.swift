import Foundation

struct ShiftNote: Codable, Identifiable {
    var id: String
    let date: Date
    var note: String
    
    init(id: String = UUID().uuidString, date: Date, note: String) {
        self.id = id
        self.date = date
        self.note = note
    }
}

class NoteManager: ObservableObject {
    @Published var notes: [ShiftNote] = []
    
    private let key = "shiftNotes"
    
    init() {
        loadNotes()
    }
    
    func addNote(_ note: String, for date: Date) {
        let newNote = ShiftNote(date: date, note: note)
        notes.append(newNote)
        saveNotes()
    }
    
    func getNote(for date: Date) -> String? {
        let calendar = Calendar.current
        return notes.first { note in
            calendar.isDate(note.date, inSameDayAs: date)
        }?.note
    }
    
    func updateNote(_ note: String, for date: Date) {
        if let index = notes.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            notes[index].note = note
            saveNotes()
        } else {
            addNote(note, for: date)
        }
    }
    
    private let calendar = Calendar.current
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ShiftNote].self, from: data) {
            notes = decoded
        }
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
} 