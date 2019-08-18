import 'package:github/common/model/Issue.dart';
import 'package:github/common/model/IssueEvent.dart';
import 'package:github/common/model/PushEventCommit.dart';
import 'package:github/common/model/Release.dart';

class DynamicItemEntity {
	DynamicItemActor actor;
	bool public;
	DynamicItemPayload payload;
	DynamicItemRepo repo;
	DateTime createdAt;
	String id;
	String type;

	String desc;

	String actionDesc;

	DynamicItemEntity({this.actor, this.public, this.payload, this.repo, this.createdAt, this.id, this.type});

	DynamicItemEntity.fromJson(Map<String, dynamic> json) {
		actor = json['actor'] != null ? new DynamicItemActor.fromJson(json['actor']) : null;
		public = json['public'];
		payload = json['payload'] != null ? new DynamicItemPayload.fromJson(json['payload']) : null;
		repo = json['repo'] != null ? new DynamicItemRepo.fromJson(json['repo']) : null;
		createdAt = json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null;
		id = json['id'];
		type = json['type'];

		_getActionAndDes(this);
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		if (this.actor != null) {
      data['actor'] = this.actor.toJson();
    }
		data['public'] = this.public;
		if (this.payload != null) {
      data['payload'] = this.payload.toJson();
    }
		if (this.repo != null) {
      data['repo'] = this.repo.toJson();
    }
		data['created_at'] = this.createdAt?.toIso8601String();
		data['id'] = this.id;
		data['type'] = this.type;
		return data;
	}


	///事件描述与动作
	_getActionAndDes(DynamicItemEntity event) {
		String actionStr;
		String des;
		switch (event.type) {
			case "CommitCommentEvent":
				actionStr = "Commit comment at " + event.repo.name;
				break;
			case "CreateEvent":
				if (event.payload.refType == "repository") {
					actionStr = "Created repository " + event.repo.name;
				} else {
					actionStr = "Created " + event.payload.refType + " " + event.payload.ref + " at " + event.repo.name;
				}
				break;
			case "DeleteEvent":
				actionStr = "Delete " + event.payload.refType + " " + event.payload.ref + " at " + event.repo.name;
				break;
			case "ForkEvent":
				String oriRepo = event.repo.name;
				String newRepo = event.actor.login + "/" + event.repo.name;
				actionStr = "Forked " + oriRepo + " to " + newRepo;
				break;
			case "GollumEvent":
				actionStr = event.actor.login + " a wiki page ";
				break;

			case "InstallationEvent":
				actionStr = event.payload.action + " an GitHub App ";
				break;
			case "InstallationRepositoriesEvent":
				actionStr = event.payload.action + " repository from an installation ";
				break;
			case "IssueCommentEvent":
				actionStr = event.payload.action + " comment on issue " + event.payload.issue.number.toString() + " in " + event.repo.name;
				des = event.payload.comment.body;
				break;
			case "IssuesEvent":
				actionStr = event.payload.action + " issue " + event.payload.issue.number.toString() + " in " + event.repo.name;
				des = event.payload.issue.title;
				break;

			case "MarketplacePurchaseEvent":
				actionStr = event.payload.action + " marketplace plan ";
				break;
			case "MemberEvent":
				actionStr = event.payload.action + " member to " + event.repo.name;
				break;
			case "OrgBlockEvent":
				actionStr = event.payload.action + " a user ";
				break;
			case "ProjectCardEvent":
				actionStr = event.payload.action + " a project ";
				break;
			case "ProjectColumnEvent":
				actionStr = event.payload.action + " a project ";
				break;

			case "ProjectEvent":
				actionStr = event.payload.action + " a project ";
				break;
			case "PublicEvent":
				actionStr = "Made " + event.repo.name + " public";
				break;
			case "PullRequestEvent":
				actionStr = event.payload.action + " pull request " + event.repo.name;
				break;
			case "PullRequestReviewEvent":
				actionStr = event.payload.action + " pull request review at" + event.repo.name;
				break;
			case "PullRequestReviewCommentEvent":
				actionStr = event.payload.action + " pull request review comment at" + event.repo.name;
				break;

			case "PushEvent":
				String ref = event.payload.ref;
				ref = ref.substring(ref.lastIndexOf("/") + 1);
				actionStr = "Push to " + ref + " at " + event.repo.name;

				des = '';
				String descSpan = '';

				int count = event.payload.commits.length;
				int maxLines = 4;
				int max = count > maxLines ? maxLines - 1 : count;

				for (int i = 0; i < max; i++) {
					PushEventCommit commit = event.payload.commits[i];
					if (i != 0) {
						descSpan += ("\n");
					}
					String sha = commit.sha.substring(0, 7);
					descSpan += sha;
					descSpan += " ";
					descSpan += commit.message;
				}
				if (count > maxLines) {
					descSpan = descSpan + "\n" + "...";
				}
				break;
			case "ReleaseEvent":
				actionStr = event.payload.action + " release " + event.payload.release.tagName + " at " + event.repo.name;
				break;
			case "WatchEvent":
				actionStr = event.payload.action + " " + event.repo.name;
				break;
		}

		this.actionDesc = actionStr;
		this.desc = des != null ? des : "";

//		return {"actionStr": actionStr, "des": des != null ? des : ""};
	}

}

class DynamicItemActor {
	String displayLogin;
	String avatarUrl;
	int id;
	String login;
	String gravatarId;
	String url;

	DynamicItemActor({this.displayLogin, this.avatarUrl, this.id, this.login, this.gravatarId, this.url});

	DynamicItemActor.fromJson(Map<String, dynamic> json) {
		displayLogin = json['display_login'];
		avatarUrl = json['avatar_url'];
		id = json['id'];
		login = json['login'];
		gravatarId = json['gravatar_id'];
		url = json['url'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['display_login'] = this.displayLogin;
		data['avatar_url'] = this.avatarUrl;
		data['id'] = this.id;
		data['login'] = this.login;
		data['gravatar_id'] = this.gravatarId;
		data['url'] = this.url;
		return data;
	}
}

class DynamicItemPayload {

	String action;

	String refType;

	String ref;

	Issue issue;

	IssueEvent comment;

	Release release;

	List<PushEventCommit> commits;

	DynamicItemPayloadForkee forkee;

	DynamicItemPayload({this.forkee, this.action});

	DynamicItemPayload.fromJson(Map<String, dynamic> json) {
		forkee = json['forkee'] != null ? new DynamicItemPayloadForkee.fromJson(json['forkee']) : null;
		action = json['action'];
		refType = json['ref_type'];
		ref = json['ref'];
		commits = (json['commits'] as List)
				?.map((e) => e == null
				? null
				: PushEventCommit.fromJson(e as Map<String, dynamic>))
				?.toList();
		comment = json['comment'] == null
				? null
				: IssueEvent.fromJson(json['comment'] as Map<String, dynamic>);
		release = json['release'] == null
				? null
				: Release.fromJson(json['release'] as Map<String, dynamic>);
		issue = json['issue'] == null
				? null
				: Issue.fromJson(json['issue'] as Map<String, dynamic>);
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		if (this.forkee != null) {
      data['forkee'] = this.forkee.toJson();
    }
		if(this.action != null) {
			data['action'] = this.action;
		}
		if(this.refType != null) {
			data['ref_type'] = this.refType;
		}
		if(this.ref != null) {
			data['ref'] = this.ref;
		}
		if(this.commits != null) {
			data['commits'] = this.commits;
		}
		if(this.comment != null) {
			data['comment'] = this.comment;
		}
		if(this.issue != null) {
			data['issue'] = this.issue;
		}
		if(this.release != null) {
			data['release'] = this.release;
		}
		return data;
	}
}

class DynamicItemPayloadForkee {
	int stargazersCount;
	String pushedAt;
	String subscriptionUrl;
	dynamic language;
	String branchesUrl;
	String issueCommentUrl;
	String labelsUrl;
	String subscribersUrl;
	String releasesUrl;
	String svnUrl;
	int id;
	int forks;
	String archiveUrl;
	String gitRefsUrl;
	String forksUrl;
	String statusesUrl;
	String sshUrl;
	dynamic license;
	String fullName;
	int size;
	String languagesUrl;
	String htmlUrl;
	String collaboratorsUrl;
	String cloneUrl;
	String name;
	String pullsUrl;
	String defaultBranch;
	String hooksUrl;
	String treesUrl;
	String tagsUrl;
	bool private;
	String contributorsUrl;
	bool hasDownloads;
	String notificationsUrl;
	int openIssuesCount;
	String description;
	String createdAt;
	int watchers;
	String keysUrl;
	String deploymentsUrl;
	bool hasProjects;
	bool archived;
	bool hasWiki;
	String updatedAt;
	bool public;
	String commentsUrl;
	String stargazersUrl;
	bool disabled;
	String gitUrl;
	bool hasPages;
	DynamicItemPayloadForkeeOwner owner;
	String commitsUrl;
	String compareUrl;
	String gitCommitsUrl;
	String blobsUrl;
	String gitTagsUrl;
	String mergesUrl;
	String downloadsUrl;
	bool hasIssues;
	String url;
	String contentsUrl;
	dynamic mirrorUrl;
	String milestonesUrl;
	String teamsUrl;
	bool fork;
	String issuesUrl;
	String eventsUrl;
	String issueEventsUrl;
	String assigneesUrl;
	int openIssues;
	int watchersCount;
	String nodeId;
	String homepage;
	int forksCount;

	DynamicItemPayloadForkee({this.stargazersCount, this.pushedAt, this.subscriptionUrl, this.language, this.branchesUrl, this.issueCommentUrl, this.labelsUrl, this.subscribersUrl, this.releasesUrl, this.svnUrl, this.id, this.forks, this.archiveUrl, this.gitRefsUrl, this.forksUrl, this.statusesUrl, this.sshUrl, this.license, this.fullName, this.size, this.languagesUrl, this.htmlUrl, this.collaboratorsUrl, this.cloneUrl, this.name, this.pullsUrl, this.defaultBranch, this.hooksUrl, this.treesUrl, this.tagsUrl, this.private, this.contributorsUrl, this.hasDownloads, this.notificationsUrl, this.openIssuesCount, this.description, this.createdAt, this.watchers, this.keysUrl, this.deploymentsUrl, this.hasProjects, this.archived, this.hasWiki, this.updatedAt, this.public, this.commentsUrl, this.stargazersUrl, this.disabled, this.gitUrl, this.hasPages, this.owner, this.commitsUrl, this.compareUrl, this.gitCommitsUrl, this.blobsUrl, this.gitTagsUrl, this.mergesUrl, this.downloadsUrl, this.hasIssues, this.url, this.contentsUrl, this.mirrorUrl, this.milestonesUrl, this.teamsUrl, this.fork, this.issuesUrl, this.eventsUrl, this.issueEventsUrl, this.assigneesUrl, this.openIssues, this.watchersCount, this.nodeId, this.homepage, this.forksCount});

	DynamicItemPayloadForkee.fromJson(Map<String, dynamic> json) {
		stargazersCount = json['stargazers_count'];
		pushedAt = json['pushed_at'];
		subscriptionUrl = json['subscription_url'];
		language = json['language'];
		branchesUrl = json['branches_url'];
		issueCommentUrl = json['issue_comment_url'];
		labelsUrl = json['labels_url'];
		subscribersUrl = json['subscribers_url'];
		releasesUrl = json['releases_url'];
		svnUrl = json['svn_url'];
		id = json['id'];
		forks = json['forks'];
		archiveUrl = json['archive_url'];
		gitRefsUrl = json['git_refs_url'];
		forksUrl = json['forks_url'];
		statusesUrl = json['statuses_url'];
		sshUrl = json['ssh_url'];
		license = json['license'];
		fullName = json['full_name'];
		size = json['size'];
		languagesUrl = json['languages_url'];
		htmlUrl = json['html_url'];
		collaboratorsUrl = json['collaborators_url'];
		cloneUrl = json['clone_url'];
		name = json['name'];
		pullsUrl = json['pulls_url'];
		defaultBranch = json['default_branch'];
		hooksUrl = json['hooks_url'];
		treesUrl = json['trees_url'];
		tagsUrl = json['tags_url'];
		private = json['private'];
		contributorsUrl = json['contributors_url'];
		hasDownloads = json['has_downloads'];
		notificationsUrl = json['notifications_url'];
		openIssuesCount = json['open_issues_count'];
		description = json['description'];
		createdAt = json['created_at'];
		watchers = json['watchers'];
		keysUrl = json['keys_url'];
		deploymentsUrl = json['deployments_url'];
		hasProjects = json['has_projects'];
		archived = json['archived'];
		hasWiki = json['has_wiki'];
		updatedAt = json['updated_at'];
		public = json['public'];
		commentsUrl = json['comments_url'];
		stargazersUrl = json['stargazers_url'];
		disabled = json['disabled'];
		gitUrl = json['git_url'];
		hasPages = json['has_pages'];
		owner = json['owner'] != null ? new DynamicItemPayloadForkeeOwner.fromJson(json['owner']) : null;
		commitsUrl = json['commits_url'];
		compareUrl = json['compare_url'];
		gitCommitsUrl = json['git_commits_url'];
		blobsUrl = json['blobs_url'];
		gitTagsUrl = json['git_tags_url'];
		mergesUrl = json['merges_url'];
		downloadsUrl = json['downloads_url'];
		hasIssues = json['has_issues'];
		url = json['url'];
		contentsUrl = json['contents_url'];
		mirrorUrl = json['mirror_url'];
		milestonesUrl = json['milestones_url'];
		teamsUrl = json['teams_url'];
		fork = json['fork'];
		issuesUrl = json['issues_url'];
		eventsUrl = json['events_url'];
		issueEventsUrl = json['issue_events_url'];
		assigneesUrl = json['assignees_url'];
		openIssues = json['open_issues'];
		watchersCount = json['watchers_count'];
		nodeId = json['node_id'];
		homepage = json['homepage'];
		forksCount = json['forks_count'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['stargazers_count'] = this.stargazersCount;
		data['pushed_at'] = this.pushedAt;
		data['subscription_url'] = this.subscriptionUrl;
		data['language'] = this.language;
		data['branches_url'] = this.branchesUrl;
		data['issue_comment_url'] = this.issueCommentUrl;
		data['labels_url'] = this.labelsUrl;
		data['subscribers_url'] = this.subscribersUrl;
		data['releases_url'] = this.releasesUrl;
		data['svn_url'] = this.svnUrl;
		data['id'] = this.id;
		data['forks'] = this.forks;
		data['archive_url'] = this.archiveUrl;
		data['git_refs_url'] = this.gitRefsUrl;
		data['forks_url'] = this.forksUrl;
		data['statuses_url'] = this.statusesUrl;
		data['ssh_url'] = this.sshUrl;
		data['license'] = this.license;
		data['full_name'] = this.fullName;
		data['size'] = this.size;
		data['languages_url'] = this.languagesUrl;
		data['html_url'] = this.htmlUrl;
		data['collaborators_url'] = this.collaboratorsUrl;
		data['clone_url'] = this.cloneUrl;
		data['name'] = this.name;
		data['pulls_url'] = this.pullsUrl;
		data['default_branch'] = this.defaultBranch;
		data['hooks_url'] = this.hooksUrl;
		data['trees_url'] = this.treesUrl;
		data['tags_url'] = this.tagsUrl;
		data['private'] = this.private;
		data['contributors_url'] = this.contributorsUrl;
		data['has_downloads'] = this.hasDownloads;
		data['notifications_url'] = this.notificationsUrl;
		data['open_issues_count'] = this.openIssuesCount;
		data['description'] = this.description;
		data['created_at'] = this.createdAt;
		data['watchers'] = this.watchers;
		data['keys_url'] = this.keysUrl;
		data['deployments_url'] = this.deploymentsUrl;
		data['has_projects'] = this.hasProjects;
		data['archived'] = this.archived;
		data['has_wiki'] = this.hasWiki;
		data['updated_at'] = this.updatedAt;
		data['public'] = this.public;
		data['comments_url'] = this.commentsUrl;
		data['stargazers_url'] = this.stargazersUrl;
		data['disabled'] = this.disabled;
		data['git_url'] = this.gitUrl;
		data['has_pages'] = this.hasPages;
		if (this.owner != null) {
      data['owner'] = this.owner.toJson();
    }
		data['commits_url'] = this.commitsUrl;
		data['compare_url'] = this.compareUrl;
		data['git_commits_url'] = this.gitCommitsUrl;
		data['blobs_url'] = this.blobsUrl;
		data['git_tags_url'] = this.gitTagsUrl;
		data['merges_url'] = this.mergesUrl;
		data['downloads_url'] = this.downloadsUrl;
		data['has_issues'] = this.hasIssues;
		data['url'] = this.url;
		data['contents_url'] = this.contentsUrl;
		data['mirror_url'] = this.mirrorUrl;
		data['milestones_url'] = this.milestonesUrl;
		data['teams_url'] = this.teamsUrl;
		data['fork'] = this.fork;
		data['issues_url'] = this.issuesUrl;
		data['events_url'] = this.eventsUrl;
		data['issue_events_url'] = this.issueEventsUrl;
		data['assignees_url'] = this.assigneesUrl;
		data['open_issues'] = this.openIssues;
		data['watchers_count'] = this.watchersCount;
		data['node_id'] = this.nodeId;
		data['homepage'] = this.homepage;
		data['forks_count'] = this.forksCount;
		return data;
	}
}

class DynamicItemPayloadForkeeOwner {
	String gistsUrl;
	String reposUrl;
	String followingUrl;
	String starredUrl;
	String login;
	String followersUrl;
	String type;
	String url;
	String subscriptionsUrl;
	String receivedEventsUrl;
	String avatarUrl;
	String eventsUrl;
	String htmlUrl;
	bool siteAdmin;
	int id;
	String gravatarId;
	String nodeId;
	String organizationsUrl;

	DynamicItemPayloadForkeeOwner({this.gistsUrl, this.reposUrl, this.followingUrl, this.starredUrl, this.login, this.followersUrl, this.type, this.url, this.subscriptionsUrl, this.receivedEventsUrl, this.avatarUrl, this.eventsUrl, this.htmlUrl, this.siteAdmin, this.id, this.gravatarId, this.nodeId, this.organizationsUrl});

	DynamicItemPayloadForkeeOwner.fromJson(Map<String, dynamic> json) {
		gistsUrl = json['gists_url'];
		reposUrl = json['repos_url'];
		followingUrl = json['following_url'];
		starredUrl = json['starred_url'];
		login = json['login'];
		followersUrl = json['followers_url'];
		type = json['type'];
		url = json['url'];
		subscriptionsUrl = json['subscriptions_url'];
		receivedEventsUrl = json['received_events_url'];
		avatarUrl = json['avatar_url'];
		eventsUrl = json['events_url'];
		htmlUrl = json['html_url'];
		siteAdmin = json['site_admin'];
		id = json['id'];
		gravatarId = json['gravatar_id'];
		nodeId = json['node_id'];
		organizationsUrl = json['organizations_url'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['gists_url'] = this.gistsUrl;
		data['repos_url'] = this.reposUrl;
		data['following_url'] = this.followingUrl;
		data['starred_url'] = this.starredUrl;
		data['login'] = this.login;
		data['followers_url'] = this.followersUrl;
		data['type'] = this.type;
		data['url'] = this.url;
		data['subscriptions_url'] = this.subscriptionsUrl;
		data['received_events_url'] = this.receivedEventsUrl;
		data['avatar_url'] = this.avatarUrl;
		data['events_url'] = this.eventsUrl;
		data['html_url'] = this.htmlUrl;
		data['site_admin'] = this.siteAdmin;
		data['id'] = this.id;
		data['gravatar_id'] = this.gravatarId;
		data['node_id'] = this.nodeId;
		data['organizations_url'] = this.organizationsUrl;
		return data;
	}
}

class DynamicItemRepo {
	String name;
	int id;
	String url;

	DynamicItemRepo({this.name, this.id, this.url});

	DynamicItemRepo.fromJson(Map<String, dynamic> json) {
		name = json['name'];
		id = json['id'];
		url = json['url'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['name'] = this.name;
		data['id'] = this.id;
		data['url'] = this.url;
		return data;
	}
}
