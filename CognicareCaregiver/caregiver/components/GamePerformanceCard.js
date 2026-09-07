import React from "react";
import { Text, View } from "react-native";
import { formatTime } from "../data/patientData";

export default function GamePerformanceCard({ game }) {
  const status =
    game.accuracy >= 90
      ? "Strong"
      : game.accuracy >= 75
      ? "Good"
      : "Needs Practice";

  return (
    <View
      style={{
        backgroundColor: "#FFFFFF",
        borderRadius: 17,
        padding: 13,
        marginBottom: 10,
        borderWidth: 1,
        borderColor: "#DDE4DF",
      }}
    >
      <View style={{ flexDirection: "row", alignItems: "center" }}>
        <View
          style={{
            width: 47,
            height: 47,
            borderRadius: 14,
            backgroundColor: "#E4F1EA",
            alignItems: "center",
            justifyContent: "center",
            marginRight: 11,
          }}
        >
          <Text style={{ fontSize: 15, color: "#4E987B", fontWeight: "900" }}>
            {game.name.substring(0, 2).toUpperCase()}
          </Text>
        </View>

        <View style={{ flex: 1 }}>
          <Text style={{ fontSize: 13, color: "#17352F", fontWeight: "800" }}>
            {game.name}
          </Text>
          <Text style={{ fontSize: 9, color: "#6E7D79", marginTop: 4 }}>
            {game.date} • {game.assistance}
          </Text>
        </View>

        <View style={{ alignItems: "flex-end" }}>
          <Text style={{ fontSize: 14, color: "#31584C", fontWeight: "900" }}>
            {game.score}/{game.total}
          </Text>
          <Text style={{ fontSize: 8, color: "#6E7D79", marginTop: 2 }}>
            Score
          </Text>
        </View>
      </View>

      <View
        style={{
          flexDirection: "row",
          justifyContent: "space-between",
          marginTop: 12,
        }}
      >
        <Metric label="Accuracy" value={`${game.accuracy}%`} />
        <Metric label="Time" value={formatTime(game.timeSeconds)} />
        <Metric label="Status" value={status} />
      </View>
    </View>
  );
}

function Metric({ label, value }) {
  return (
    <View
      style={{
        width: "31%",
        backgroundColor: "#F7F8F3",
        borderRadius: 11,
        padding: 8,
        alignItems: "center",
      }}
    >
      <Text style={{ fontSize: 11, fontWeight: "900", color: "#31584C" }}>
        {value}
      </Text>
      <Text style={{ fontSize: 7, color: "#6E7D79", marginTop: 3 }}>
        {label}
      </Text>
    </View>
  );
}
