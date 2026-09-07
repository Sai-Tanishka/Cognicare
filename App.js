import React, { useState } from "react";

import {
  SafeAreaView,
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  StatusBar,
} from "react-native";

import { Ionicons, MaterialCommunityIcons } from "@expo/vector-icons";

export default function App() {
  const [activeTab, setActiveTab] = useState("Home");

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />

      {/* Header */}
      <View style={styles.header}>
        <View>
          <Text style={styles.greeting}>Hello, Ananya!</Text>

          <Text style={styles.subtitle}>
            Here's how Tanishka is doing today
          </Text>
        </View>

        <TouchableOpacity style={styles.profileButton}>
          <Ionicons name="person" size={22} color="#FFFFFF" />
        </TouchableOpacity>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
      >

        {/* Patient Card */}
        <View style={styles.patientCard}>

          <View style={styles.patientAvatar}>
            <Ionicons
              name="person"
              size={34}
              color="#4F7668"
            />
          </View>

          <View style={styles.patientInfo}>
            <Text style={styles.patientName}>Tanishka</Text>

            <Text style={styles.patientAge}>
              Age 72 • Dementia Care
            </Text>

            <View style={styles.statusRow}>
              <View style={styles.statusDot} />

              <Text style={styles.statusText}>
                Stable today
              </Text>
            </View>
          </View>

          <TouchableOpacity>
            <Ionicons
              name="chevron-forward"
              size={22}
              color="#476C60"
            />
          </TouchableOpacity>

        </View>


        {/* Today's Overview */}

        <Text style={styles.sectionTitle}>
          Today's Overview
        </Text>

        <View style={styles.overviewRow}>

          <View style={styles.overviewCard}>

            <View style={styles.iconCircle}>
              <Ionicons
                name="checkmark-circle-outline"
                size={26}
                color="#4F8B72"
              />
            </View>

            <Text style={styles.overviewNumber}>
              4/5
            </Text>

            <Text style={styles.overviewLabel}>
              Activities
            </Text>

          </View>


          <View style={styles.overviewCard}>

            <View style={styles.iconCircle}>
              <Ionicons
                name="happy-outline"
                size={26}
                color="#D49B3B"
              />
            </View>

            <Text style={styles.overviewNumber}>
              Calm
            </Text>

            <Text style={styles.overviewLabel}>
              Current Mood
            </Text>

          </View>

        </View>


        {/* Attention Needed */}

        <Text style={styles.sectionTitle}>
          Attention Needed
        </Text>

        <View style={styles.alertCard}>

          <View style={styles.alertIcon}>
            <Ionicons
              name="alert-circle-outline"
              size={27}
              color="#D27B63"
            />
          </View>

          <View style={styles.alertContent}>

            <Text style={styles.alertTitle}>
              Medication reminder missed
            </Text>

            <Text style={styles.alertDescription}>
              Morning medication • 10:00 AM
            </Text>

          </View>

          <TouchableOpacity>
            <Ionicons
              name="chevron-forward"
              size={20}
              color="#777"
            />
          </TouchableOpacity>

        </View>


        {/* Quick Actions */}

        <Text style={styles.sectionTitle}>
          Quick Actions
        </Text>

        <View style={styles.actionGrid}>

          <TouchableOpacity style={styles.actionCard}>
            <View style={styles.actionIcon}>
              <Ionicons
                name="alarm-outline"
                size={27}
                color="#557E70"
              />
            </View>

            <Text style={styles.actionText}>
              Reminders
            </Text>
          </TouchableOpacity>


          <TouchableOpacity style={styles.actionCard}>
            <View style={styles.actionIcon}>
              <Ionicons
                name="bar-chart-outline"
                size={27}
                color="#557E70"
              />
            </View>

            <Text style={styles.actionText}>
              Progress
            </Text>
          </TouchableOpacity>


          <TouchableOpacity style={styles.actionCard}>
            <View style={styles.actionIcon}>
              <Ionicons
                name="heart-outline"
                size={27}
                color="#557E70"
              />
            </View>

            <Text style={styles.actionText}>
              Mood
            </Text>
          </TouchableOpacity>


          <TouchableOpacity style={styles.actionCard}>
            <View style={styles.actionIcon}>
              <Ionicons
                name="call-outline"
                size={27}
                color="#557E70"
              />
            </View>

            <Text style={styles.actionText}>
              Contact
            </Text>
          </TouchableOpacity>

        </View>


        {/* Recent Cognitive Activity */}

        <Text style={styles.sectionTitle}>
          Recent Cognitive Activity
        </Text>

        <View style={styles.activityCard}>

          <ActivityRow
            icon="grid"
            title="Pattern Recall"
            score="9/10"
            color="#4F9679"
          />

          <ActivityRow
            icon="alphabetical"
            title="Word Match"
            score="8/10"
            color="#D78B57"
          />

          <ActivityRow
            icon="numeric"
            title="Number Sequence"
            score="7/10"
            color="#5E91B6"
          />

          <ActivityRow
            icon="image-outline"
            title="Image Memory"
            score="9/10"
            color="#A56EA6"
          />

        </View>


        {/* AI Insight */}

        <Text style={styles.sectionTitle}>
          AI Insight
        </Text>

        <View style={styles.insightCard}>

          <View style={styles.insightIcon}>
            <Ionicons
              name="sparkles-outline"
              size={25}
              color="#557E70"
            />
          </View>

          <View style={{ flex: 1 }}>

            <Text style={styles.insightTitle}>
              Positive progress
            </Text>

            <Text style={styles.insightText}>
              Tanishka performed better in memory
              activities this week compared with last week.
            </Text>

          </View>

        </View>

      </ScrollView>


      {/* Bottom Navigation */}

      <View style={styles.bottomNav}>

        <NavItem
          icon="home"
          label="Home"
          active={activeTab === "Home"}
          onPress={() => setActiveTab("Home")}
        />

        <NavItem
          icon="game-controller-outline"
          label="Activity"
          active={activeTab === "Activity"}
          onPress={() => setActiveTab("Activity")}
        />

        <NavItem
          icon="stats-chart-outline"
          label="Progress"
          active={activeTab === "Progress"}
          onPress={() => setActiveTab("Progress")}
        />

        <NavItem
          icon="person-outline"
          label="Profile"
          active={activeTab === "Profile"}
          onPress={() => setActiveTab("Profile")}
        />

      </View>

    </SafeAreaView>
  );
}


/* Activity Row */

function ActivityRow({
  icon,
  title,
  score,
  color,
}) {

  return (

    <View style={styles.activityRow}>

      <View
        style={[
          styles.activityIcon,
          { backgroundColor: color + "20" },
        ]}
      >

        <MaterialCommunityIcons
          name={icon}
          size={22}
          color={color}
        />

      </View>

      <Text style={styles.activityTitle}>
        {title}
      </Text>

      <Text style={styles.activityScore}>
        {score}
      </Text>

      <Ionicons
        name="chevron-forward"
        size={18}
        color="#999"
      />

    </View>

  );
}


/* Navigation Item */

function NavItem({
  icon,
  label,
  active,
  onPress,
}) {

  return (

    <TouchableOpacity
      style={styles.navItem}
      onPress={onPress}
    >

      <Ionicons
        name={icon}
        size={23}
        color={active ? "#416D60" : "#89918D"}
      />

      <Text
        style={[
          styles.navText,
          active && styles.activeNavText,
        ]}
      >
        {label}
      </Text>

    </TouchableOpacity>

  );
}


/* Styles */

const styles = StyleSheet.create({

  container: {
    flex: 1,
    backgroundColor: "#F8F8F3",
  },

  header: {
    paddingHorizontal: 22,
    paddingTop: 15,
    paddingBottom: 12,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },

  greeting: {
    fontSize: 26,
    fontWeight: "700",
    color: "#193D35",
  },

  subtitle: {
    fontSize: 14,
    color: "#75807B",
    marginTop: 5,
    maxWidth: 260,
  },

  profileButton: {
    width: 43,
    height: 43,
    borderRadius: 22,
    backgroundColor: "#477365",
    alignItems: "center",
    justifyContent: "center",
  },

  scrollContent: {
    paddingHorizontal: 20,
    paddingBottom: 30,
  },

  patientCard: {
    backgroundColor: "#E5EFE8",
    borderRadius: 22,
    padding: 17,
    flexDirection: "row",
    alignItems: "center",
    marginTop: 8,
  },

  patientAvatar: {
    width: 58,
    height: 58,
    borderRadius: 29,
    backgroundColor: "#D1E2D7",
    alignItems: "center",
    justifyContent: "center",
  },

  patientInfo: {
    flex: 1,
    marginLeft: 14,
  },

  patientName: {
    fontSize: 19,
    fontWeight: "700",
    color: "#23483F",
  },

  patientAge: {
    fontSize: 13,
    color: "#738079",
    marginTop: 3,
  },

  statusRow: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 6,
  },

  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: "#57926F",
    marginRight: 6,
  },

  statusText: {
    fontSize: 12,
    color: "#57926F",
    fontWeight: "600",
  },

  sectionTitle: {
    fontSize: 18,
    fontWeight: "700",
    color: "#26463F",
    marginTop: 24,
    marginBottom: 12,
  },

  overviewRow: {
    flexDirection: "row",
    gap: 12,
  },

  overviewCard: {
    flex: 1,
    backgroundColor: "#FFFFFF",
    borderRadius: 18,
    padding: 16,
    minHeight: 125,
  },

  iconCircle: {
    width: 43,
    height: 43,
    borderRadius: 22,
    backgroundColor: "#E7F1EA",
    justifyContent: "center",
    alignItems: "center",
  },

  overviewNumber: {
    fontSize: 20,
    fontWeight: "700",
    color: "#284B41",
    marginTop: 10,
  },

  overviewLabel: {
    fontSize: 12,
    color: "#7D8782",
    marginTop: 2,
  },

  alertCard: {
    backgroundColor: "#FFF3ED",
    borderRadius: 18,
    padding: 15,
    flexDirection: "row",
    alignItems: "center",
  },

  alertIcon: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: "#FBE3D9",
    alignItems: "center",
    justifyContent: "center",
  },

  alertContent: {
    flex: 1,
    marginLeft: 12,
  },

  alertTitle: {
    fontSize: 14,
    fontWeight: "700",
    color: "#5D4037",
  },

  alertDescription: {
    fontSize: 12,
    color: "#8B756C",
    marginTop: 4,
  },

  actionGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 12,
  },

  actionCard: {
    width: "47%",
    backgroundColor: "#FFFFFF",
    borderRadius: 18,
    padding: 16,
    flexDirection: "row",
    alignItems: "center",
  },

  actionIcon: {
    width: 42,
    height: 42,
    borderRadius: 14,
    backgroundColor: "#E5F0E9",
    alignItems: "center",
    justifyContent: "center",
  },

  actionText: {
    fontSize: 13,
    fontWeight: "600",
    color: "#35584E",
    marginLeft: 10,
  },

  activityCard: {
    backgroundColor: "#FFFFFF",
    borderRadius: 20,
    paddingHorizontal: 15,
  },

  activityRow: {
    minHeight: 67,
    flexDirection: "row",
    alignItems: "center",
    borderBottomWidth: 1,
    borderBottomColor: "#F0F0EC",
  },

  activityIcon: {
    width: 42,
    height: 42,
    borderRadius: 13,
    alignItems: "center",
    justifyContent: "center",
  },

  activityTitle: {
    flex: 1,
    fontSize: 14,
    fontWeight: "600",
    color: "#374A45",
    marginLeft: 12,
  },

  activityScore: {
    fontSize: 14,
    fontWeight: "700",
    color: "#4C7769",
    marginRight: 10,
  },

  insightCard: {
    backgroundColor: "#E7F0E8",
    borderRadius: 20,
    padding: 16,
    flexDirection: "row",
    alignItems: "flex-start",
    marginBottom: 20,
  },

  insightIcon: {
    width: 42,
    height: 42,
    borderRadius: 14,
    backgroundColor: "#D3E4D7",
    alignItems: "center",
    justifyContent: "center",
    marginRight: 12,
  },

  insightTitle: {
    fontSize: 15,
    fontWeight: "700",
    color: "#31584C",
    marginBottom: 4,
  },

  insightText: {
    fontSize: 12,
    lineHeight: 18,
    color: "#66766F",
  },

  bottomNav: {
    height: 72,
    backgroundColor: "#FFFFFF",
    borderTopWidth: 1,
    borderTopColor: "#E8E8E3",
    flexDirection: "row",
    justifyContent: "space-around",
    alignItems: "center",
  },

  navItem: {
    alignItems: "center",
    justifyContent: "center",
    minWidth: 65,
  },

  navText: {
    fontSize: 11,
    color: "#89918D",
    marginTop: 4,
  },

  activeNavText: {
    color: "#416D60",
    fontWeight: "700",
  },

});