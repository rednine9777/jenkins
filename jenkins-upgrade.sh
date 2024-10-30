jenkins:
  agentProtocols:
  - "JNLP4-connect"
  - "Ping"
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false
  clouds:
  - kubernetes:
      containerCap: 10
      containerCapStr: "10"
      jenkinsTunnel: "jenkins-agent:50000"
      jenkinsUrl: "http://172.18.0.100"
      maxRequestsPerHost: 32
      maxRequestsPerHostStr: "32"
      name: "kubernetes"
      namespace: "jenkins"  # Jenkins 네임스페이스로 설정
      podLabels:
      - key: "jenkins/jenkins-jenkins-slave"
        value: "true"
      serverUrl: "https://kubernetes.default"
      templates:
      - name: "default"
        label: "jenkins-jenkins-slave"
        nodeUsageMode: NORMAL
        hostNetwork: false
        podRetention: "never"
        runAsUser: "1000"
        runAsGroup: "993"
        serviceAccount: "jenkins"
        yamlMergeStrategy: "override"
        containers:
        - name: "jnlp"
          image: "jenkins/inbound-agent:4.3-4"
          args: "${computer.jnlpmac} ${computer.name}"
          command: ""
          envVars:
          - envVar:
              key: "JENKINS_URL"
              value: "http://172.18.0.100"
          livenessProbe:
            failureThreshold: 0
            initialDelaySeconds: 0
            periodSeconds: 0
            successThreshold: 0
            timeoutSeconds: 0
          resourceLimitCpu: "512m"
          resourceLimitMemory: "512Mi"
          resourceRequestCpu: "512m"
          resourceRequestMemory: "512Mi"
          workingDir: "/home/jenkins"
          volumeMounts:
          - name: "docker-binary"
            mountPath: "/usr/bin/docker"
            subPath: "docker"
          - name: "docker-socket"
            mountPath: "/var/run/docker.sock"
          - name: "kubectl-binary"
            mountPath: "/usr/bin/kubectl"
            subPath: "kubectl"
        volumes:
        - name: "docker-binary"
          hostPath:
            path: "/usr/bin/docker"
            type: File
        - name: "docker-socket"
          hostPath:
            path: "/var/run/docker.sock"
            type: Socket
        - name: "kubectl-binary"
          hostPath:
            path: "/usr/local/bin/kubectl"
            type: File
  crumbIssuer:
    standard:
      excludeClientIPFromCrumb: true
  disableRememberMe: false
  disabledAdministrativeMonitors:
  - "hudson.model.UpdateCenter$CoreUpdateMonitor"
  - "jenkins.diagnostics.RootUrlNotSetMonitor"
  - "jenkins.security.UpdateSiteWarningsMonitor"
  labelAtoms:
  - name: "master"
  markupFormatter: "plainText"
  mode: NORMAL
  myViewsTabBar: "standard"
  numExecutors: 2  # 노드의 익스큐터 수 설정
  primaryView:
    all:
      name: "all"
  projectNamingStrategy: "standard"
  quietPeriod: 5
  remotingSecurity:
    enabled: true
  scmCheckoutRetryCount: 0
  securityRealm: "legacy"
  slaveAgentPort: 50000
  updateCenter:
    sites:
    - id: "default"
      url: "https://raw.githubusercontent.com/IaC-Source/Jenkins-updateCenter/main/update-center.json"
  views:
  - all:
      name: "all"
  viewsTabBar: "standard"
security:
  apiToken:
    creationOfLegacyTokenEnabled: false
    tokenGenerationOnCreationEnabled: false
    usageStatisticsEnabled: true
  sSHD:
    port: -1
unclassified:
  buildDiscarders:
    configuredBuildDiscarders:
    - "jobBuildDiscarder"
  fingerprints:
    fingerprintCleanupDisabled: false
    storage: "file"
  gitSCM:
    createAccountBasedOnEmail: false
    showEntireCommitSummaryInChanges: false
    useExistingAccountWithSameEmail: false
  junitTestResultStorage:
    storage: "file"
  location:
    adminAddress: "address not configured yet <nobody@nowhere>"
  mailer:
    charset: "UTF-8"
    useSsl: false
    useTls: false
  pollSCM:
    pollingThreadCount: 10
tool:
  git:
    installations:
    - home: "git"
      name: "Default"

