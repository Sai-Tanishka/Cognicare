import React from "react";
import { ScrollView, Text, View } from "react-native";

import PerformanceChart from "../components/PerformanceChart";
import ReminderCard from "../components/ReminderCard";
import {
  patient,
  games,
  weeklyPerformance,
  reminders,
  moodHistory,
  caregiverObservations,
  calculateReport,
  formatTime,
} from "../data/patientData";

export default function ReportScreen() {
  const report = calculateReport();

  return (
    <View style={styles.screen}>
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.content}
      >
        <Text style={styles.pageTitle}>Patient Care Report</Text>
        <Text style={styles.pageSubtitle}>
          {patient.name} • Cognitive, care and medication-support analysis
        </Text>

        <View style={styles.period}>
          <Text style={styles.periodSmall}>REPORT PERIOD</Text>
          <Text style={styles.periodValue}>2 Sep – 8 Sep 2026</Text>
        </View>

        <View style={styles.summary}>
          <View style={{ flex: 1 }}>
            <Text style={styles.summaryLabel}>Overall cognitive activity</Text>
            <Text style={styles.summaryValue}>{report.averageAccuracy}%</Text>
            <Text style={styles.summaryText}>
              Average accuracy from {report.completedGames} recorded games
            </Text>
          </View>

          <View style={styles.circle}>
            <Text style={styles.circleText}>{report.trend >= 0 ? "+" : ""}{report.trend}%</Text>
            <Text style={styles.circleLabel}>weekly trend</Text>
          </View>
        </View>

        <Text style={styles.section}>Performance Graph</Text>
        <PerformanceChart data={weeklyPerformance} />

        <Text style={styles.section}>Performance Analysis</Text>

        <AnalysisRow
          title="Strongest activity"
          value={
            report.strongestGame
              ? `${report.strongestGame.name} • ${report.strongestGame.accuracy}%`
              : "No data"
          }
          detail="Activity with the highest recorded accuracy."
        />

        <AnalysisRow
          title="Needs more practice"
          value={
            report.needsPractice
              ? `${report.needsPractice.name} • ${report.needsPractice.accuracy}%`
              : "No data"
          }
          detail="Lower recorded accuracy may be useful for targeted practice."
          warning
        />

        <AnalysisRow
          title="Average completion time"
          value={formatTime(report.averageTime)}
          detail="Average time across completed games."
        />

        <AnalysisRow
          title="Independent participation"
          value={`${report.independentCount}/${report.completedGames} games`}
          detail="Based on recorded caregiver/app observations."
        />

        <Text style={styles.section}>Game-by-Game Report</Text>

        {games.map((game) => (
          <View key={game.id} style={styles.gameRow}>
            <View style={{ flex: 1 }}>
              <Text style={styles.gameName}>{game.name}</Text>
              <Text style={styles.gameDate}>{game.date}</Text>
            </View>
            <View style={styles.gameMetric}>
              <Text style={styles.gameMetricValue}>{game.accuracy}%</Text>
              <Text style={styles.gameMetricLabel}>
                {formatTime(game.timeSeconds)}
              </Text>
            </View>
          </View>
        ))}

        <Text style={styles.section}>Mood / Emotional Observation</Text>

        <View style={styles.moodCard}>
          {moodHistory.map((item) => (
            <View key={item.day} style={styles.moodItem}>
              <Text style={styles.moodDay}>{item.day}</Text>
              <Text style={styles.moodValue}>{item.mood}</Text>
              <View style={styles.moodBar}>
                <View style={[styles.moodFill, { width: `${item.value * 20}%` }]} />
              </View>
            </View>
          ))}
        </View>

        <Text style={styles.section}>Medication & Reminder Review</Text>

        {reminders.map((item) => (
          <ReminderCard key={item.id} item={item} />
        ))}

        <View style={styles.medicationBox}>
          <Text style={styles.medicationTitle}>Medication follow-up</Text>
          <Text style={styles.medicationText}>
            {report.pendingMedication > 0
              ? "A medication reminder is still pending. The caregiver should verify the physical medication supply and confirm whether the patient actually took the prescribed medicine."
              : "No pending medication reminder is currently recorded."}
          </Text>

          <View style={styles.doctorBox}>
            <Text style={styles.doctorTitle}>Healthcare professional review</Text>
            <Text style={styles.doctorText}>
              The application must not automatically change medication,
              dosage or treatment. Any medication decision should be made
              by the responsible doctor or healthcare worker after reviewing
              the app information and physical observations.
            </Text>
          </View>
        </View>

        <Text style={styles.section}>Caregiver Observations</Text>

        <View style={styles.observationBox}>
          {caregiverObservations.map((item, index) => (
            <Text key={index} style={styles.observation}>
              • {item}
            </Text>
          ))}
        </View>

        <Text style={styles.section}>AI-Assisted Final Analysis</Text>

        <View style={styles.aiBox}>
          <Text style={styles.aiTitle}>✦ Care Summary</Text>

          <Text style={styles.aiText}>
            {patient.name} participated in {report.completedGames} recorded
            cognitive activities with an average accuracy of {report.averageAccuracy}%.
            The strongest activity was{" "}
            {report.strongestGame ? report.strongestGame.name : "not available"}.
          </Text>

          <Text style={styles.aiText}>
            {report.needsPractice
              ? `${report.needsPractice.name} showed the lowest recorded accuracy at ${report.needsPractice.accuracy}%, so the caregiver can consider additional practice and observation for this activity.`
              : "More activity data is needed for targeted recommendations."}
          </Text>

          <Text style={styles.aiText}>
            Weekly recorded accuracy changed by {report.trend >= 0 ? "+" : ""}
            {report.trend} percentage points from the first to the latest
            day in the displayed period.
          </Text>

          <View style={styles.recommendation}>
            <Text style={styles.recommendationTitle}>Recommended next actions</Text>
            <Text style={styles.recommendationText}>1. Continue regular cognitive activities.</Text>
            <Text style={styles.recommendationText}>2. Give extra practice to lower-performing games.</Text>
            <Text style={styles.recommendationText}>3. Record caregiver observations after activities.</Text>
            <Text style={styles.recommendationText}>4. Follow up missed hydration/medication reminders.</Text>
            <Text style={styles.recommendationText}>5. Share the report with the healthcare professional when appropriate.</Text>
          </View>
        </View>

        <Text style={styles.section}>Final Care Analysis</Text>

        <View style={styles.finalBox}>
          <View style={styles.statusRow}>
            <View style={styles.statusDot} />
            <Text style={styles.statusText}>Continued caregiver monitoring</Text>
          </View>

          <Text style={styles.finalText}>
            Current app data shows active participation in cognitive
            activities with generally stable performance. Some activities
            require additional time or practice.
          </Text>

          <Text style={styles.finalText}>
            This report combines patient app activity, reminder status,
            mood entries and caregiver observations. It is a care-support
            report, not a medical diagnosis.
          </Text>
        </View>
      </ScrollView>
    </View>
  );
}

function AnalysisRow({ title, value, detail, warning }) {
  return (
    <View
      style={[
        styles.analysisRow,
        warning && { borderLeftColor: "#D9A646" },
      ]}
    >
      <Text style={styles.analysisTitle}>{title}</Text>
      <Text style={styles.analysisValue}>{value}</Text>
      <Text style={styles.analysisDetail}>{detail}</Text>
    </View>
  );
}

const styles = {
  screen: { flex: 1, backgroundColor: "#F7F8F3" },
  content: { padding: 20, paddingBottom: 35 },
  pageTitle: { fontSize: 27, fontWeight: "900", color: "#17352F" },
  pageSubtitle: { fontSize: 11, color: "#6E7D79", marginTop: 5, lineHeight: 17 },
  period: { backgroundColor: "#E4EEE8", borderRadius: 15, padding: 13, marginTop: 15 },
  periodSmall: { fontSize: 8, color: "#31584C", fontWeight: "900", letterSpacing: 1 },
  periodValue: { fontSize: 12, color: "#17352F", fontWeight: "800", marginTop: 4 },
  summary: {
    backgroundColor: "#FFFFFF",
    borderRadius: 20,
    padding: 17,
    flexDirection: "row",
    alignItems: "center",
    borderWidth: 1,
    borderColor: "#DDE4DF",
    marginTop: 10,
  },
  summaryLabel: { fontSize: 11, color: "#6E7D79" },
  summaryValue: { fontSize: 38, fontWeight: "900", color: "#31584C", marginTop: 3 },
  summaryText: { fontSize: 8, color: "#6E7D79" },
  circle: {
    width: 78,
    height: 78,
    borderRadius: 39,
    backgroundColor: "#E4EEE8",
    borderWidth: 6,
    borderColor: "#31584C",
    alignItems: "center",
    justifyContent: "center",
  },
  circleText: { fontSize: 17, color: "#31584C", fontWeight: "900" },
  circleLabel: { fontSize: 7, color: "#6E7D79", marginTop: 2 },
  section: { fontSize: 18, fontWeight: "900", color: "#17352F", marginTop: 22, marginBottom: 10 },
  analysisRow: {
    backgroundColor: "#FFFFFF",
    borderRadius: 16,
    padding: 13,
    borderWidth: 1,
    borderColor: "#DDE4DF",
    borderLeftWidth: 4,
    borderLeftColor: "#4E987B",
    marginBottom: 9,
  },
  analysisTitle: { fontSize: 9, color: "#6E7D79" },
  analysisValue: { fontSize: 13, color: "#17352F", fontWeight: "900", marginTop: 4 },
  analysisDetail: { fontSize: 8, color: "#6E7D79", marginTop: 4, lineHeight: 14 },
  gameRow: {
    backgroundColor: "#FFFFFF",
    borderRadius: 14,
    padding: 12,
    flexDirection: "row",
    alignItems: "center",
    borderWidth: 1,
    borderColor: "#DDE4DF",
    marginBottom: 8,
  },
  gameName: { fontSize: 11, color: "#17352F", fontWeight: "800" },
  gameDate: { fontSize: 8, color: "#6E7D79", marginTop: 3 },
  gameMetric: { alignItems: "flex-end" },
  gameMetricValue: { fontSize: 13, color: "#31584C", fontWeight: "900" },
  gameMetricLabel: { fontSize: 8, color: "#6E7D79", marginTop: 2 },
  moodCard: {
    backgroundColor: "#FFFFFF",
    borderRadius: 18,
    padding: 14,
    borderWidth: 1,
    borderColor: "#DDE4DF",
  },
  moodItem: { marginBottom: 9 },
  moodDay: { fontSize: 8, color: "#6E7D79" },
  moodValue: { fontSize: 10, color: "#17352F", fontWeight: "800", marginTop: 2 },
  moodBar: { height: 5, borderRadius: 3, backgroundColor: "#EEF1EE", marginTop: 4, overflow: "hidden" },
  moodFill: { height: "100%", backgroundColor: "#9A7BB4", borderRadius: 3 },
  medicationBox: { backgroundColor: "#F7EBDD", borderRadius: 18, padding: 15, marginTop: 3 },
  medicationTitle: { fontSize: 13, color: "#17352F", fontWeight: "900" },
  medicationText: { fontSize: 9, color: "#6D7169", lineHeight: 16, marginTop: 6 },
  doctorBox: { backgroundColor: "#FFFDF8", borderRadius: 12, padding: 11, marginTop: 10 },
  doctorTitle: { fontSize: 9, color: "#9B6C1D", fontWeight: "900" },
  doctorText: { fontSize: 8, color: "#77736A", lineHeight: 14, marginTop: 4 },
  observationBox: { backgroundColor: "#F2EEE3", borderRadius: 18, padding: 15 },
  observation: { fontSize: 9, color: "#6A706B", lineHeight: 17 },
  aiBox: { backgroundColor: "#E4EEE8", borderRadius: 19, padding: 16 },
  aiTitle: { fontSize: 13, color: "#17352F", fontWeight: "900" },
  aiText: { fontSize: 10, color: "#5F716B", lineHeight: 17, marginTop: 8 },
  recommendation: { backgroundColor: "#FFFFFF", borderRadius: 13, padding: 12, marginTop: 12 },
  recommendationTitle: { fontSize: 10, color: "#17352F", fontWeight: "900", marginBottom: 5 },
  recommendationText: { fontSize: 8, color: "#6E7D79", lineHeight: 16 },
  finalBox: { backgroundColor: "#FFFFFF", borderRadius: 19, padding: 16, borderWidth: 1, borderColor: "#DDE4DF" },
  statusRow: { flexDirection: "row", alignItems: "center", marginBottom: 9 },
  statusDot: { width: 9, height: 9, borderRadius: 5, backgroundColor: "#4E987B", marginRight: 7 },
  statusText: { fontSize: 10, color: "#4E987B", fontWeight: "900" },
  finalText: { fontSize: 9, color: "#6E7D79", lineHeight: 16, marginBottom: 7 },
};
