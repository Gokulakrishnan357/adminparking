class Profile {
  CreateProfileResponseData? data;

  Profile({this.data});

  Profile.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null
        ? CreateProfileResponseData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CreateProfileResponseData {
  CreateCompanyProfile? createCompanyProfile;

  CreateProfileResponseData({this.createCompanyProfile});

  CreateProfileResponseData.fromJson(Map<String, dynamic> json) {
    createCompanyProfile = json['createCompanyProfile'] != null
        ? CreateCompanyProfile.fromJson(json['createCompanyProfile'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (createCompanyProfile != null) {
      data['createCompanyProfile'] = createCompanyProfile!.toJson();
    }
    return data;
  }
}

class CreateCompanyProfile {
  String? message;
  bool? success;
  CompanyProfileData? data;

  CreateCompanyProfile({this.message, this.success, this.data});

  CreateCompanyProfile.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    success = json['success'];
    data = json['data'] != null
        ? CompanyProfileData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CompanyProfileData {
  int? companyprofileId;
  int? companyuserid;
  String? createdAt;
  String? email;
  String? imageUrl;
  String? name;
  String? location;
  String? updatedAt;

  CompanyProfileData({
    this.companyprofileId,
    this.companyuserid,
    this.createdAt,
    this.email,
    this.imageUrl,
    this.name,
    this.location,
    this.updatedAt,
  });

  CompanyProfileData.fromJson(Map<String, dynamic> json) {
    companyprofileId = json['companyprofileId'];
    companyuserid = json['companyuserid'];
    createdAt = json['createdAt'];
    email = json['email'];
    imageUrl = json['imageUrl'];
    name = json['name'];
    location = json['name'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['companyprofileId'] = companyprofileId;
    data['companyuserid'] = companyuserid;
    data['createdAt'] = createdAt;
    data['email'] = email;
    data['imageUrl'] = imageUrl;
    data['name'] = name;
    data['location'] = location;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
