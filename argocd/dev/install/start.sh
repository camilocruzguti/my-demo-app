argocd app create argocd \                                                                                                                                               
--repo https://github.com/camilocruzguti/my-demo-app.git \
--path ./argocd/dev \
--dest-server https://kubernetes.default.svc \
--dest-namespace argocd \
--sync-policy auto