import React, { useState } from "react";
import { ScrollView, Text, TouchableOpacity, View } from "react-native";

import GamePerformanceCard from "../components/GamePerformanceCard";
import { games, patient } from "../data/patientData";

export default function ActivitiesScreen({ onNavigate }) {
  const [validated, setValidated] = useState([]);

  const toggleValidation = (id) => {
    setValidated((old) =>
      old.includes(id) ? old.filter((item) => item !== id) : [...old, id]
    );
  };

  return (
    <View style={styles.screen}>
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.content}
      >
        <Text style={styles.pageTitle}>Patient Activities</Text>
        <Text style={styles.pageSubtitle}>
          Review {patient.name}'s cognitive games and validate caregiver observations.
        </Text>

        <View style={styles.info}>
          <Text style={styles.infoTitle}>How validation works</Text>
          <Text style={styles.infoText}>
            Game scores and completion times come from the patient app.
            The caregiver confirms whether the patient played independently
            or required assistance. Both records are used in the care report.
          </Text>
        </View>

        {games.map((game) => {
          const isValidated = validated.includes(game.id);

          return (
            <View key={game.id}>
              <GamePerformanceCard game={game} />

              <TouchableOpacity
                style={[
                  styles.validateButton,
                  isValidated && styles.validated,
                ]}
                onPress={() => toggleValidation(game.id)}
              >
                <Text
                  style={[
                    styles.validateText,
                    isValidated && styles.validatedText,
                  ]}
                >
                  {isValidated
                    ? "✓ Caregiver Validation Added"
                    : "Add Caregiver Validation"}
                </Text>
              </TouchableOpacity>
            </View>
          );
        })}

        <TouchableOpacity
          style={styles.reportButton}
          onPress={() => onNavigate("report")}
        >
          <Text style={styles.reportButtonText}>View Patient Report →</Text>
        </TouchableOpacity>
      </ScrollView>
    </View>
  );
}

const styles = {
  screen: { flex: 1, backgroundColor: "#F7F8F3" },
  content: { padding: 20, paddingBottom: 30 },
  pageTitle: { fontSize: 27, fontWeight: "900", color: "#17352F" },
  pageSubtitle: {
    fontSize: 11,
    color: "#6E7D79",
    lineHeight: 17,
    marginTop: 5,
    marginBottom: 15,
  },
  info: {
    backgroundColor: "#E7F1F7",
    borderRadius: 16,
    padding: 14,
    marginBottom: 15,
  },
  infoTitle: { fontSize: 12, fontWeight: "900", color: "#17352F" },
  infoText: { fontSize: 9, color: "#6E7D79", lineHeight: 16, marginTop: 5 },
  validateButton: {
    backgroundColor: "#31584C",
    borderRadius: 11,
    paddingVertical: 10,
    alignItems: "center",
    marginTop: -3,
    marginBottom: 12,
  },
  validated: {
    backgroundColor: "#E4F1EA",
    borderWidth: 1,
    borderColor: "#C8DED2",
  },
  validateText: { color: "#FFFFFF", fontSize: 10, fontWeight: "900" },
  validatedText: { color: "#4E987B" },
  reportButton: {
    backgroundColor: "#31584C",
    borderRadius: 16,
    paddingVertical: 14,
    alignItems: "center",
    marginTop: 5,
  },
  reportButtonText: { color: "#FFFFFF", fontSize: 12, fontWeight: "900" },
};
