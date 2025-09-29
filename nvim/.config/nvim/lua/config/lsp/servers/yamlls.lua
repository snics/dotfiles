-- YAML Language Server Configuration with Kubernetes support

local M = {}

-- Export configuration table (for vim.lsp.config)
M.config = {
  settings = {
      yaml = {
        schemaStore = {
          -- Disable built-in schemaStore support since we use SchemaStore.nvim
          enable = false,
          -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
          url = "",
        },
        schemas = (function()
          -- 1. SchemaStore.nvim for all standard schemas (highest priority)
          local schemas = require('schemastore').yaml.schemas()
          
          -- 2. Kubernetes Schema - Smart Loading (overrides SchemaStore Kubernetes if needed)
          local k8s_ok, kubernetes = pcall(require, 'kubernetes')
          if k8s_ok then
            local schema_path = kubernetes.yamlls_schema()
            if schema_path then
              -- Use kubernetes.nvim for all YAML files when available
              schemas[schema_path] = "*.{yaml,yml}"
            end
          else
            -- Fallback to static Kubernetes schema for specific patterns
            schemas["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/refs/heads/master/v1.34.0/all.json"] = {
              -- Core Workload Resources
              "*pod*.{yaml,yml}", "*po*.{yaml,yml}",
              "*service*.{yaml,yml}", "*svc*.{yaml,yml}",
              "*deployment*.{yaml,yml}", "*deploy*.{yaml,yml}",
              "*replicaset*.{yaml,yml}", "*rs*.{yaml,yml}",
              "*daemonset*.{yaml,yml}", "*ds*.{yaml,yml}",
              "*statefulset*.{yaml,yml}", "*sts*.{yaml,yml}",
              "*job*.{yaml,yml}",
              "*cronjob*.{yaml,yml}", "*cj*.{yaml,yml}",
              
              -- Config & Storage
              "*configmap*.{yaml,yml}", "*cm*.{yaml,yml}",
              "*secret*.{yaml,yml}",
              "*persistentvolume*.{yaml,yml}", "*pv*.{yaml,yml}",
              "*persistentvolumeclaim*.{yaml,yml}", "*pvc*.{yaml,yml}",
              "*storageclass*.{yaml,yml}", "*sc*.{yaml,yml}",
              
              -- Networking
              "*ingress*.{yaml,yml}", "*ing*.{yaml,yml}",
              "*networkpolicy*.{yaml,yml}", "*netpol*.{yaml,yml}",
              "*endpoints*.{yaml,yml}", "*ep*.{yaml,yml}",
              "*endpointslice*.{yaml,yml}",
              
              -- Security & Access
              "*serviceaccount*.{yaml,yml}", "*sa*.{yaml,yml}",
              "*role*.{yaml,yml}",
              "*rolebinding*.{yaml,yml}",
              "*clusterrole*.{yaml,yml}",
              "*clusterrolebinding*.{yaml,yml}",
              "*podsecuritypolicy*.{yaml,yml}", "*psp*.{yaml,yml}",
              
              -- Advanced Workloads
              "*horizontalpodautoscaler*.{yaml,yml}", "*hpa*.{yaml,yml}",
              "*verticalpodautoscaler*.{yaml,yml}", "*vpa*.{yaml,yml}",
              "*poddisruptionbudget*.{yaml,yml}", "*pdb*.{yaml,yml}",
              
              -- API & Custom Resources
              "*customresourcedefinition*.{yaml,yml}", "*crd*.{yaml,yml}",
              "*apiservice*.{yaml,yml}",
              "*mutatingwebhookconfiguration*.{yaml,yml}",
              "*validatingwebhookconfiguration*.{yaml,yml}",
              
              -- Nodes & Cluster
              "*node*.{yaml,yml}", "*no*.{yaml,yml}",
              "*namespace*.{yaml,yml}", "*ns*.{yaml,yml}",
              "*resourcequota*.{yaml,yml}", "*quota*.{yaml,yml}",
              "*limitrange*.{yaml,yml}", "*limits*.{yaml,yml}",
              
              -- Events & Monitoring
              "*event*.{yaml,yml}", "*ev*.{yaml,yml}",
              "*componentstatus*.{yaml,yml}", "*cs*.{yaml,yml}",
              
              -- Special patterns
              "*.k8s.{yaml,yml}",
              "*kubernetes*.{yaml,yml}",
              "k8s/**/*.{yaml,yml}",
              "kubernetes/**/*.{yaml,yml}",
              "manifests/**/*.{yaml,yml}",
            }
          end
          return schemas
        end)(),
        format = { 
          enable = true,
          singleQuote = false,
          bracketSpacing = true,
        },
        validate = true,
        completion = true,
        hover = true,
        -- Kubernetes support now handled by kubernetes.nvim plugin
      }
    },
  -- Improved file type detection
  filetypes = { 
    "yaml", 
    "yml", 
    "yaml.docker-compose",
    "yaml.gitlab",
    "yaml.ansible"
  },
  -- Root directory detection
  root_dir = vim.fs.root(0, {
    ".git",
    "docker-compose.yml",
    "docker-compose.yaml",
    "Chart.yaml",
    "values.yaml",
    "ansible.cfg",
    ".gitlab-ci.yml"
  }),
}

return M