class CropMilestoneData {
    static List<Map<String, dynamic>> getMilestonesForCrop(String cropName, String plotName) {
    String normalizedCrop = cropName.toLowerCase().trim();

    if (normalizedCrop.contains('maize')) {
      return [
        {
          'dap': 21,
          'title': 'First Weeding',
          'body': 'Your Maize plot "$plotName" is 3 weeks old. Start weeding to prevent nutrient competition.',
        },
}