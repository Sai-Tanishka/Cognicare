import React, { useState } from "react";
import { ScrollView, Text, TouchableOpacity, View } from "react-native";

import { reminders, games, patient } from "../data/patientData";

export default function AlertsScreen() {
  const [reviewed, setReviewed] = useState([]);

  const alerts = reminders.filter(
    (item) => item.status === "Missed" || item.status === "Pending"
  );

  return (
    <View style={styles.screen}>
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.content}
      >
        <Text style={styles.pageTitle}>Alerts</Text>
        <Text style={styles.pageSubtitle}>
          Important care items requiring caregiver attention.
        </Text>

        {alerts.map((item) => {
          const done = reviewed.includes(item.id);

          return (
            <View key={item.id} style={styles.alertCard}>
              <View style={styles.alertIcon}>
                <Text style={styles.alertIconText}>!</Text>
              </View>

              <View style={{ flex: 1 }}>
                <Text style={styles.alertTitle}>{item.title}</Text>
                <Text style={styles.alertText}>
                  {item.status === "Missed"
                    ? `${patient.name} did not confirm this reminder.`
                    : `Scheduled for ${item.time}.`}
                </Text>

                <TouchableOpacity
                  style={[styles.reviewButton, done && styles.reviewedButton]}
                  onPress={() =>
                    setReviewed((old) =>
                      old.includes(item.id)
                        ? old.filter((id) => id !== item.id)
                        : [...old, item.id]
                    )
                  }
                >
                  <Text style={[styles.reviewText, done && styles.reviewedText]}>
                    {done ? "✓ Reviewed" : "Mark as Reviewed"}
                  </Text>
                </TouchableOpacity>
              </View>
            </View>
          );
        })}

        <View style={styles.info}>
          <Text style={styles.infoTitle}>Activity alert</Text>
          <Text style={styles.infoText}>
            {games.length} cognitive game records are available for the current
            caregiver report.
          </Text>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = {
  screen: { flex: 1, backgroundColor: "#F7F8F3" },
  content: { padding: 20, paddingBottom: 30 },
  pageTitle: { fontSize: 27, fontWeight: "900", color: "#17352F" },
  pageSubtitle: { fontSize: 11, color: "#6E7D79", marginTop: 5, marginBottom: 17 },
  alertCard: {
    backgroundColor: "#FFFFFF",
    borderRadius: 17,
    padding: 14,
    flexDirection: "row",
    borderWidth: 1,
    borderColor: "#DDE4DF",
    borderLeftWidth: 4,
    borderLeftColor: "#D96B68",
    marginBottom: 10,
  },
  alertIcon: {
    width: 38,
    height: 38,
    borderRadius: 12,
    backgroundColor: "#FBE8E6",
    alignItems: "center",
    justifyContent: "center",
    marginRight: 10,
  },
  alertIconText: { color: "#D96B68", fontSize: 17, fontWeight: "900" },
  alertTitle: { fontSize: 12, color: "#17352F", fontWeight: "900" },
  alertText: { fontSize: 9, color: "#6E7D79", lineHeight: 15, marginTop: 4 },
  reviewButton: { backgroundColor: "#31584C", borderRadius: 10, paddingVertical: 8, alignItems: "center", marginTop: 8 },
  reviewedButton: { backgroundColor: "#E4F1EA" },
  reviewText: { color: "#FFFFFF", fontSize: 9, fontWeight: "900" },
  reviewedText: { color: "#4E987B" },
  info: { backgroundColor: "#E4EEE8", borderRadius: 16, padding: 14, marginTop: 4 },
  infoTitle: { fontSize: 12, color: "#17352F", fontWeight: "900" },
  infoText: { fontSize: 9, color: "#6E7D79", lineHeight: 16, marginTop: 5 },
};
