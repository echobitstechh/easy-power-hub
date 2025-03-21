

import 'package:easyph/core/data/models/product.dart';
import 'package:easyph/core/data/models/profile.dart';

import 'category.dart';

class Project {
  String? id;
  String? projectTitle;
  String? projectDescription;
  String? orgName;
  String? projectReel;
  List<Media>? media;
  Category? category;
  int? projectTarget;
  int? amountRaised;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? targetLocal;
  String? amountRaisedLocal;

  Project({
    this.id,
    this.projectTitle,
    this.projectDescription,
    this.orgName,
    this.projectReel,
    this.media,
    this.category,
    this.projectTarget,
    this.amountRaised,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.targetLocal,
    this.amountRaisedLocal // Initialize this in the constructor
  });

  Project.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['_id'];
    projectTitle = json['project_title'];
    projectDescription = json['project_description'];
    orgName = json['org_name'];
    projectReel = json['project_reel'];
    if (json['media'] != null) {
      media = <Media>[];
      json['media'].forEach((v) {
        media!.add(Media.fromJson(v));
      });
    }
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
    projectTarget = json['project_target'];
    amountRaised = json['amount_raised'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    targetLocal = json['target_local'];
    amountRaisedLocal = json['amount_raised_local'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['project_title'] = projectTitle;
    data['project_description'] = projectDescription;
    data['org_name'] = orgName;
    data['project_reel'] = projectReel;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    data['project_target'] = projectTarget;
    data['amount_raised'] = amountRaised;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['target_local'] = targetLocal;
    data['amount_raised_local'] = amountRaisedLocal;
    return data;
  }
}

class Comment {
  String? id;
  String? comment;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? replyTo;
  Profile? user;
  bool isExpanded;

  Comment({
    this.id,
    this.comment,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.replyTo,
    this.user,
    this.isExpanded = false,
  });

  Comment.fromJson(Map<String, dynamic> json)
      : isExpanded = false,
        id = json['_id'],
        comment = json['comment'],
        status = json['status'],
        createdAt = json['createdAt'],
        updatedAt = json['updatedAt'],
        replyTo = json['replyTo'],
        user = json['user'] != null ? Profile.fromJson(json['user']) : null;


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['comment'] = comment;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['replyTo'] = replyTo;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}



class Member {
  String? firstname;
  String? lastname;
  ProfilePic? profilePic;

  Member({this.firstname, this.lastname, this.profilePic});

  Member.fromJson(Map<String, dynamic> json) {
    firstname = json['firstname'];
    lastname = json['lastname'];
    profilePic = json['profile_pic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['profile_pic'] = profilePic;
    return data;
  }
}

class ProjectResource {
  Project? project;
  List<Member>? members;
  List<Comment>? recentComments;
  List<ProjectChecklist>? projectChecklist;

  ProjectResource({this.project, this.members, this.recentComments,  this.projectChecklist,});

  ProjectResource.fromJson(Map<String, dynamic> json) {
    project = json['project'] != null ? Project.fromJson(json['project']) : null;

    if (json['members'] != null) {
      members = <Member>[];
      json['members'].forEach((v) {
        members!.add(Member.fromJson(v));
      });
    }

    if (json['recentComments'] != null) {
      recentComments = <Comment>[];
      json['recentComments'].forEach((v) {
        recentComments!.add(Comment.fromJson(v));
      });
    }

    if (json['projectChecklist'] != null) {
      projectChecklist = <ProjectChecklist>[];
      json['projectChecklist'].forEach((v) {
        projectChecklist!.add(ProjectChecklist.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (project != null) {
      data['project'] = project!.toJson();
    }
    if (members != null) {
      data['members'] = members!.map((v) => v.toJson()).toList();
    }
    if (recentComments != null) {
      data['recentComments'] = recentComments!.map((v) => v.toJson()).toList();
    }
    if (projectChecklist != null) {
      data['projectChecklist'] =
          projectChecklist!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProjectChecklist {
  String? id;
  String? projectId;
  String? name;
  bool? completed;
  String? createdAt;
  String? updatedAt;

  ProjectChecklist({
    this.id,
    this.projectId,
    this.name,
    this.completed,
    this.createdAt,
    this.updatedAt,
  });

  ProjectChecklist.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    projectId = json['project'];
    name = json['name'];
    completed = json['completed'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['project'] = projectId;
    data['name'] = name;
    data['completed'] = completed;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}


class Media {
  String? id;
  String? url;

  Media({this.id, this.url});

  Media.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['url'] = url;
    return data;
  }
}
