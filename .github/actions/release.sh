#!/usr/bin/env bash

set -ex

if [[ "${GITHUB_REF}" == refs/heads/master || "${GITHUB_REF}" == refs/tags/* ]]; then      
  minor_ver="${PHP_VER%.*}"
  minor_tag="${minor_ver}"
  major_tag="${minor_ver%.*}"

  if [[ -n "${PHP_DEV}" ]]; then            
    if [[ "${WODBY_USER_ID}" == "501" ]]; then
      minor_tag="${minor_tag}-dev-macos"
      if [[ -n "${LATEST_MAJOR}" ]]; then    
        major_tag="${major_tag}-dev-macos"
      fi
    else 
      minor_tag="${minor_tag}-dev"
      if [[ -n "${LATEST_MAJOR}" ]]; then
        major_tag="${major_tag}-dev"
      fi
    fi
  fi

  tags=("${minor_tag}")
  if [[ -n "${LATEST_MAJOR}" ]]; then
     tags+=("${major_tag}")
  fi

  if [[ "${GITHUB_REF}" == refs/tags/* ]]; then
    stability_tag=("${GITHUB_REF##*/}")
    tags=("${minor_tag}-${stability_tag}")
    if [[ -n "${LATEST_MAJOR}" ]]; then
      tags+=("${major_tag}-${stability_tag}")
    fi
  else          
    if [[ -n "${LATEST}" ]]; then
      if [[ -z "${PHP_DEV}" ]]; then
        tags+=("latest")
      else
        if [[ "${WODBY_USER_ID}" == "501" ]]; then
          tags+=("dev-macos")
        else
          tags+=("dev")
        fi
      fi
    fi
  fi

  for tag in "${tags[@]}"; do
    make buildx-imagetools-create IMAGETOOLS_TAG=${tag}
  done
fi