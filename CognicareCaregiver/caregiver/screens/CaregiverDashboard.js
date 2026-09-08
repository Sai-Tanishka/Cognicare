import React from "react";
import { ScrollView, Text, TouchableOpacity, View } from "react-native";

import Header from "../components/Header";
import StatCard from "../components/StatCard";
import GamePerformanceCard from "../components/GamePerformanceCard";
import ReminderCard from "../components/ReminderCard";
import {
  patient,
  games,
  reminders,
  calculateReport,
} from "../data/patientData";

export default function CaregiverDashboard({ onNavigate, selectedPatient }) {
  const report = calculateReport();
  const displayedPatient = selectedPatient || patient;

  return (
    <View style={styles.screen}>
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.content}
      >
        <Header
          title={`Hello, ${displayedPatient.caregiverName}!`}
          subtitle={`Here's how ${displayedPatient.name} is doing today.`}
        />

        <View style={styles.patientCard}>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>{displayedPatient.name.charAt(0)}</Text>
          </View>

          <View style={{ flex: 1 }}>
            <Text style={styles.patientName}>{displayedPatient.name}</Text>
            <Text style={styles.patientInfo}>
              {displayedPatient.age} years • {displayedPatient.gender}
            </Text>
            <Text style={styles.active}>● {patient.lastActive}</Text>
          </View>

          <Text style={styles.patientTag}>PATIENT</Text>
        </View>

        <Text style={styles.sectionTitle}>Today's Overview</Text>

        <View style={styles.grid}>
          <StatCard icon="✓" value={report.completedGames} label="Games Played" />
          <StatCard icon="%" value={`${report.averageAccuracy}%`} label="Avg. Accuracy" />
          <StatCard icon="◷" value="4" label="Care Reminders" />
          <StatCard icon="!" value={report.missedReminders} label="Attention Needed" danger />
        </View>

        <Text style={styles.sectionTitle}>Attention Needed</Text>

        {reminders
          .filter((item) => item.status === "Missed" || item.status === "Pending")
          .map((item) => (
            <ReminderCard key={item.id} item={item} />
          ))}

        <Text style={styles.sectionTitle}>Recent Cognitive Activity</Text>

        {games.slice(0, 4).map((game) => (
          <GamePerformanceCard key={game.id} game={game} />
        ))}

        <TouchableOpacity
          style={styles.primaryButton}
          onPress={() => onNavigate("activity")}
        >
          <View style={{ flex: 1 }}>
            <Text style={styles.buttonTitle}>Review Activities</Text>
            <Text style={styles.buttonSubtitle}>
              Validate patient performance and observations
            </Text>
          </View>
          <Text style={styles.arrow}>›</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.reportButton}
          onPress={() => onNavigate("report")}
        >
          <View style={{ flex: 1 }}>
            <Text style={styles.reportTitle}>Patient Care Report</Text>
            <Text style={styles.reportSubtitle}>
              Graph + analysis + medication follow-up
            </Text>
          </View>
          <Text style={styles.reportArrow}>›</Text>
        </TouchableOpacity>

        <View style={styles.aiCard}>
          <Text style={styles.aiTitle}>✦ Caregiver Insight</Text>
          <Text style={styles.aiText}>
            {report.strongestGame
              ? `${report.strongestGame.name} is currently the strongest recorded activity at ${report.strongestGame.accuracy}% accuracy.`
              : "More cognitive activity data is required."}
          </Text>

          <Text style={styles.aiText}>
            {report.needsPractice
              ? `${report.needsPractice.name} may benefit from additional practice because its recorded accuracy is ${report.needsPractice.accuracy}%.`
              : ""}
          </Text>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = {
  screen: { flex: 1, backgroundColor: "#F7F8F3" },
  content: { padding: 20, paddingBottom: 30 },
  patientCard: {
    backgroundColor: "#FFFFFF",
    borderRadius: 20,
    padding: 15,
    flexDirection: "row",
    alignItems: "center",
    borderWidth: 1,
    borderColor: "#DDE4DF",
    marginBottom: 22,
  },
  avatar: {
    width: 58,
    height: 58,
    borderRadius: 29,
    backgroundColor: "#E4EEE8",
    alignItems: "center",
    justifyContent: "center",
    marginRight: 12,
  },
  avatarText: { fontSize: 25, fontWeight: "900", color: "#31584C" },
  patientName: { fontSize: 18, fontWeight: "900", color: "#17352F" },
  patientInfo: { fontSize: 10, color: "#6E7D79", marginTop: 3 },
  active: { fontSize: 9, color: "#4E987B", marginTop: 6, fontWeight: "700" },
  patientTag: {
    fontSize: 8,
    color: "#31584C",
    fontWeight: "900",
    backgroundColor: "#E4EEE8",
    paddingHorizontal: 8,
    paddingVertical: 6,
    borderRadius: 9,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "900",
    color: "#17352F",
    marginBottom: 11,
    marginTop: 2,
  },
  grid: {
    flexDirection: "row",
    flexWrap: "wrap",
    justifyContent: "space-between",
    marginBottom: 16,
  },
  primaryButton: {
    backgroundColor: "#31584C",
    borderRadius: 18,
    padding: 15,
    flexDirection: "row",
    alignItems: "center",
    marginTop: 5,
  },
  buttonTitle: { color: "#FFFFFF", fontSize: 13, fontWeight: "900" },
  buttonSubtitle: { color: "#DCEAE4", fontSize: 9, marginTop: 4 },
  arrow: { color: "#FFFFFF", fontSize: 27 },
  reportButton: {
    backgroundColor: "#FFFFFF",
    borderRadius: 18,
    padding: 15,
    flexDirection: "row",
    alignItems: "center",
    borderWidth: 1,
    borderColor: "#DDE4DF",
    marginTop: 10,
  },
  reportTitle: { color: "#17352F", fontSize: 14, fontWeight: "900" },
  reportSubtitle: { color: "#6E7D79", fontSize: 9, marginTop: 4 },
  reportArrow: { color: "#31584C", fontSize: 27 },
  aiCard: {
    backgroundColor: "#E4EEE8",
    borderRadius: 18,
    padding: 16,
    marginTop: 10,
  },
  aiTitle: { color: "#17352F", fontSize: 13, fontWeight: "900" },
  aiText: { color: "#5F716B", fontSize: 10, lineHeight: 17, marginTop: 7 },
};
