import React from "react";
import { ScrollView, Text, TouchableOpacity, View } from "react-native";

import { patient, memoryItems } from "../data/patientData";

export default function PatientProfileScreen({ onLogout, selectedPatient }) {
  const displayedPatient = selectedPatient || patient;
  return (
    <View style={styles.screen}>
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.content}
      >
        <Text style={styles.pageTitle}>Patient Profile</Text>
        <Text style={styles.pageSubtitle}>
          Patient information used by the caregiver for personalized support.
        </Text>

        <View style={styles.profileCard}>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>{displayedPatient.name.charAt(0)}</Text>
          </View>
          <Text style={styles.name}>{displayedPatient.name}</Text>
          <Text style={styles.info}>
            {displayedPatient.age} years • {displayedPatient.gender}
          </Text>
          <Text style={styles.active}>● Active today</Text>
        </View>

        <Text style={styles.section}>Care Information</Text>

        <InfoRow label="Preferred language" value={displayedPatient.preferredLanguage} />
        <InfoRow label="Caregiver" value={displayedPatient.caregiverName} />
        <InfoRow label="Interaction mode" value={displayedPatient.careMode} />

        <Text style={styles.section}>Memory Assistance</Text>

        <View style={styles.memoryCard}>
          {memoryItems.map((item) => (
            <View key={item.name} style={styles.memoryRow}>
              <View style={styles.memoryAvatar}>
                <Text style={styles.memoryLetter}>{item.name.charAt(0)}</Text>
              </View>

              <View style={{ flex: 1 }}>
                <Text style={styles.memoryName}>{item.name}</Text>
                <Text style={styles.memoryRelation}>{item.relation}</Text>
                <Text style={styles.memoryDetail}>{item.detail}</Text>
              </View>
            </View>
          ))}
        </View>

        <View style={styles.voiceCard}>
          <Text style={styles.voiceTitle}>Voice-assisted care</Text>
          <Text style={styles.voiceText}>
            The patient can interact with the patient app using voice
            commands when game interaction is difficult. The caregiver
            dashboard is used to review the resulting activity and care data.
          </Text>
        </View>

        <TouchableOpacity style={styles.logoutButton} onPress={onLogout}>
          <Text style={styles.logoutText}>Log Out</Text>
        </TouchableOpacity>
      </ScrollView>
    </View>
  );
}

function InfoRow({ label, value }) {
  return (
    <View style={styles.infoRow}>
      <Text style={styles.infoLabel}>{label}</Text>
      <Text style={styles.infoValue}>{value}</Text>
    </View>
  );
}

const styles = {
  screen: { flex: 1, backgroundColor: "#F7F8F3" },
  content: { padding: 20, paddingBottom: 30 },
  pageTitle: { fontSize: 27, fontWeight: "900", color: "#17352F" },
  pageSubtitle: { fontSize: 11, color: "#6E7D79", lineHeight: 17, marginTop: 5 },
  profileCard: {
    backgroundColor: "#FFFFFF",
    borderRadius: 20,
    padding: 20,
    alignItems: "center",
    borderWidth: 1,
    borderColor: "#DDE4DF",
    marginTop: 15,
  },
  avatar: { width: 78, height: 78, borderRadius: 39, backgroundColor: "#E4EEE8", alignItems: "center", justifyContent: "center" },
  avatarText: { fontSize: 34, color: "#31584C", fontWeight: "900" },
  name: { fontSize: 22, color: "#17352F", fontWeight: "900", marginTop: 10 },
  info: { fontSize: 10, color: "#6E7D79", marginTop: 4 },
  active: { fontSize: 9, color: "#4E987B", fontWeight: "800", marginTop: 8 },
  section: { fontSize: 18, color: "#17352F", fontWeight: "900", marginTop: 22, marginBottom: 10 },
  infoRow: { backgroundColor: "#FFFFFF", borderRadius: 14, padding: 13, flexDirection: "row", justifyContent: "space-between", borderWidth: 1, borderColor: "#DDE4DF", marginBottom: 8 },
  infoLabel: { fontSize: 9, color: "#6E7D79" },
  infoValue: { fontSize: 9, color: "#17352F", fontWeight: "800", maxWidth: "55%", textAlign: "right" },
  memoryCard: { backgroundColor: "#FFFFFF", borderRadius: 18, paddingHorizontal: 14, borderWidth: 1, borderColor: "#DDE4DF" },
  memoryRow: { flexDirection: "row", alignItems: "center", paddingVertical: 13, borderBottomWidth: 1, borderBottomColor: "#EDF0ED" },
  memoryAvatar: { width: 43, height: 43, borderRadius: 22, backgroundColor: "#F0EAF5", alignItems: "center", justifyContent: "center", marginRight: 10 },
  memoryLetter: { color: "#9A7BB4", fontSize: 17, fontWeight: "900" },
  memoryName: { fontSize: 12, color: "#17352F", fontWeight: "800" },
  memoryRelation: { fontSize: 9, color: "#31584C", marginTop: 2 },
  memoryDetail: { fontSize: 8, color: "#6E7D79", marginTop: 2 },
  voiceCard: { backgroundColor: "#E7F1F7", borderRadius: 17, padding: 15, marginTop: 12 },
  voiceTitle: { fontSize: 12, color: "#17352F", fontWeight: "900" },
  voiceText: { fontSize: 9, color: "#6E7D79", lineHeight: 16, marginTop: 5 },
  logoutButton: { borderWidth: 1, borderColor: "#B64747", borderRadius: 14, paddingVertical: 14, alignItems: "center", marginTop: 24 },
  logoutText: { color: "#B64747", fontSize: 15, fontWeight: "800" },
};
