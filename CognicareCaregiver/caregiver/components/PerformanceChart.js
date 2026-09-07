import React from "react";
import { Text, View } from "react-native";

export default function PerformanceChart({ data }) {
  return (
    <View
      style={{
        backgroundColor: "#FFFFFF",
        borderRadius: 19,
        padding: 15,
        borderWidth: 1,
        borderColor: "#DDE4DF",
      }}
    >
      <Text style={{ fontSize: 13, fontWeight: "800", color: "#17352F" }}>
        Weekly Cognitive Performance
      </Text>

      <Text style={{ fontSize: 9, color: "#6E7D79", marginTop: 4 }}>
        Average accuracy from recorded cognitive games
      </Text>

      <View
        style={{
          height: 210,
          flexDirection: "row",
          marginTop: 15,
        }}
      >
        <View
          style={{
            width: 30,
            height: 165,
            justifyContent: "space-between",
            alignItems: "flex-end",
            paddingBottom: 20,
          }}
        >
          <Text style={styles.axis}>100</Text>
          <Text style={styles.axis}>75</Text>
          <Text style={styles.axis}>50</Text>
          <Text style={styles.axis}>25</Text>
          <Text style={styles.axis}>0</Text>
        </View>

        <View style={{ flex: 1, height: 190 }}>
          {[100, 75, 50, 25].map((line) => (
            <View
              key={line}
              style={{
                position: "absolute",
                left: 0,
                right: 0,
                bottom: `${line - 4}%`,
                borderTopWidth: 1,
                borderTopColor: "#E9EDE9",
              }}
            />
          ))}

          <View
            style={{
              height: 190,
              flexDirection: "row",
              justifyContent: "space-around",
              alignItems: "flex-end",
            }}
          >
            {data.map((item) => (
              <View
                key={item.day}
                style={{ flex: 1, alignItems: "center" }}
              >
                <Text
                  style={{
                    fontSize: 7,
                    color: "#31584C",
                    fontWeight: "800",
                    marginBottom: 4,
                  }}
                >
                  {item.accuracy}%
                </Text>

                <View
                  style={{
                    width: 24,
                    height: 135,
                    borderRadius: 8,
                    backgroundColor: "#EEF1EE",
                    justifyContent: "flex-end",
                    overflow: "hidden",
                  }}
                >
                  <View
                    style={{
                      width: "100%",
                      height: `${item.accuracy}%`,
                      backgroundColor: "#31584C",
                      borderRadius: 8,
                    }}
                  />
                </View>

                <Text
                  style={{
                    fontSize: 8,
                    color: "#6E7D79",
                    marginTop: 5,
                  }}
                >
                  {item.day}
                </Text>
              </View>
            ))}
          </View>
        </View>
      </View>
    </View>
  );
}

const styles = {
  axis: {
    fontSize: 8,
    color: "#6E7D79",
  },
};
