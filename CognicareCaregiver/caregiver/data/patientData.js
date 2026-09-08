/*
  SINGLE DATA ADAPTER FOR THE CAREGIVER UI.

  For the SIH project, replace the values in this file with data received
  from the existing patient database/API created by your team.

  The caregiver UI does NOT create a second patient database.
  It only reads patient activity/care data and displays analysis.

  Expected backend data:
  - patient
  - games
  - reminders
  - mood
  - caregiver observations
*/

export const patient = {
  id: "P001",
  name: "Tanishka",
  age: 72,
  gender: "Female",
  preferredLanguage: "English",
  caregiverName: "Ananya",
  careMode: "Gaming + Voice Assistance",
  lastActive: "Today, 10:42 AM",
};

export const patients = [
  patient,
  {
    id: "P002",
    name: "Ravi Kumar",
    age: 76,
    gender: "Male",
    preferredLanguage: "English",
    caregiverName: "Ananya",
    careMode: "Gaming + Voice Assistance",
    lastActive: "Yesterday, 6:15 PM",
  },
];

export const games = [
  {
    id: "G001",
    name: "Pattern Recall",
    date: "08 Sep",
    score: 10,
    total: 10,
    accuracy: 100,
    timeSeconds: 28,
    completed: true,
    assistance: "Independent",
  },
  {
    id: "G002",
    name: "Word Match",
    date: "08 Sep",
    score: 8,
    total: 10,
    accuracy: 80,
    timeSeconds: 74,
    completed: true,
    assistance: "Minimal assistance",
  },
  {
    id: "G003",
    name: "Number Sequence",
    date: "07 Sep",
    score: 7,
    total: 10,
    accuracy: 70,
    timeSeconds: 102,
    completed: true,
    assistance: "Extra time required",
  },
  {
    id: "G004",
    name: "Image Memory",
    date: "07 Sep",
    score: 9,
    total: 10,
    accuracy: 90,
    timeSeconds: 56,
    completed: true,
    assistance: "Independent",
  },
  {
    id: "G005",
    name: "Pattern Recall",
    date: "06 Sep",
    score: 8,
    total: 10,
    accuracy: 80,
    timeSeconds: 41,
    completed: true,
    assistance: "Independent",
  },
];

export const weeklyPerformance = [
  { day: "Mon", accuracy: 55 },
  { day: "Tue", accuracy: 68 },
  { day: "Wed", accuracy: 82 },
  { day: "Thu", accuracy: 62 },
  { day: "Fri", accuracy: 88 },
  { day: "Sat", accuracy: 91 },
  { day: "Sun", accuracy: 82 },
];

export const reminders = [
  {
    id: "R001",
    type: "Medication",
    title: "Morning Medication",
    time: "08:00 AM",
    status: "Taken",
  },
  {
    id: "R002",
    type: "Hydration",
    title: "Hydration",
    time: "11:00 AM",
    status: "Missed",
  },
  {
    id: "R003",
    type: "Medication",
    title: "Afternoon Medication",
    time: "02:00 PM",
    status: "Pending",
  },
  {
    id: "R004",
    type: "Cognitive Activity",
    title: "Cognitive Activity",
    time: "04:00 PM",
    status: "Completed",
  },
];

export const moodHistory = [
  { day: "Mon", mood: "Calm", value: 4 },
  { day: "Tue", mood: "Happy", value: 5 },
  { day: "Wed", mood: "Calm", value: 4 },
  { day: "Thu", mood: "Neutral", value: 3 },
  { day: "Fri", mood: "Happy", value: 5 },
  { day: "Sat", mood: "Calm", value: 4 },
  { day: "Sun", mood: "Calm", value: 4 },
];

export const caregiverObservations = [
  "Patient completed most activities independently.",
  "Number Sequence required additional time.",
  "Hydration reminder was missed once.",
];

export const memoryItems = [
  { name: "Ananya", relation: "Daughter", detail: "Primary caregiver" },
  { name: "Home", relation: "Familiar place", detail: "Main residence" },
  { name: "Dr. Sharma", relation: "Doctor", detail: "Healthcare contact" },
];

export function calculateReport() {
  const completedGames = games.filter((game) => game.completed);

  const averageAccuracy = completedGames.length
    ? Math.round(
        completedGames.reduce((sum, game) => sum + game.accuracy, 0) /
          completedGames.length
      )
    : 0;

  const averageTime = completedGames.length
    ? Math.round(
        completedGames.reduce((sum, game) => sum + game.timeSeconds, 0) /
          completedGames.length
      )
    : 0;

  const independentCount = completedGames.filter(
    (game) => game.assistance === "Independent"
  ).length;

  const strongestGame =
    completedGames.length > 0
      ? [...completedGames].sort((a, b) => b.accuracy - a.accuracy)[0]
      : null;

  const needsPractice =
    completedGames.length > 0
      ? [...completedGames].sort((a, b) => a.accuracy - b.accuracy)[0]
      : null;

  const missedReminders = reminders.filter(
    (item) => item.status === "Missed"
  ).length;

  const pendingMedication = reminders.filter(
    (item) =>
      item.type === "Medication" && item.status === "Pending"
  ).length;

  const trend =
    weeklyPerformance.length >= 2
      ? weeklyPerformance[weeklyPerformance.length - 1].accuracy -
        weeklyPerformance[0].accuracy
      : 0;

  return {
    completedGames: completedGames.length,
    averageAccuracy,
    averageTime,
    independentCount,
    strongestGame,
    needsPractice,
    missedReminders,
    pendingMedication,
    trend,
  };
}

export function formatTime(seconds) {
  const minutes = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${String(minutes).padStart(2, "0")}:${String(secs).padStart(
    2,
    "0"
  )}`;
}
