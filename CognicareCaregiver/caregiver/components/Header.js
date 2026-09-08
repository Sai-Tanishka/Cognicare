import React from "react";
import { Text, View } from "react-native";

export default function Header({ title, subtitle }) {
  return (
    <View style={{ marginBottom: 20 }}>
      <Text style={{ fontSize: 26, fontWeight: "900", color: "#17352F" }}>
        {title}
      </Text>
      {subtitle ? (
        <Text
          style={{
            fontSize: 12,
            color: "#6E7D79",
            marginTop: 5,
            lineHeight: 18,
          }}
        >
          {subtitle}
        </Text>
      ) : null}
    </View>
  );
}
